Global.cmp = Global.cmp or {}
Global.cmp.custom_loaded_packages = Global.cmp.custom_loaded_packages or {}
BLT.CustomPackageManager = {}

local C = BLT.CustomPackageManager
C.custom_packages = {}
C.ext_convert = { dds = "texture", png = "texture", tga = "texture", jpg = "texture" }

--Hopefully will be functional at some point.

function C:RegisterPackage(id, directory, config)
    local func_name = "CustomPackageManager:RegisterPackage"
    if (not Utils:CheckParamsValidty({ id, directory, config },
            {
                func_name = func_name,
                params = {
                    { type = "string", allow_nil = false },
                    { type = "string", allow_nil = false },
                    { type = "table", allow_nil = false }
                }
            })) then
        return false
    end
    id = id:key()
    if self.custom_packages[id] then
        BLT:LogF(LogLevel.ERROR, "PackageManager", "Package with ID '%s' already exists! Returning...", tostring(id))
        return false
    end

    self.custom_packages[id] = { dir = directory, config = config }

    return true
end

function C:LoadPackage(id)
    id = id:key()
    if self.custom_packages[id] then
        local pck = self.custom_packages[id]
        self:LoadPackageConfig(pck.dir, pck.config)
        Global.cmp.custom_loaded_packages[id] = true
        return true
    end
end

function C:UnLoadPackage(id)
    id = id:key()
    if self.custom_packages[id] then
        local pck = self.custom_packages[id]
        self:UnloadPackageConfig(pck.config)
        Global.cmp.custom_loaded_packages[id] = false
        return false
    end
end

function C:PackageLoaded(id)
    return Global.cmp.custom_loaded_packages[id:key()]
end

function C:HasPackage(id)
    return not not self.custom_packages[id:key()]
end

function C:LoadPackageConfig(directory, config)
    if not SystemFS then
        BLT:Log(LogLevel.ERROR, "PackageManager",
            "SystemFS does not exist! Custom Packages cannot function without this! Do you have an outdated game version?")
        return
    end
    if config.load_clbk and not config.load_clbk() then
        return
    end

    local loading = {}
    for i, child in ipairs(config) do
        if type(child) == "table" then
            local typ = child._meta
            local path = child.path
            local load_clbk = child.load_clbk
            if not load_clbk or load_clbk(path, typ) then
                if typ == "unit_load" or typ == "add" then
                    self:LoadPackageConfig(directory, child)
                elseif typ and path then
                    path = Utils.Path:Normalize(path)
                    local ids_ext = Idstring(self.ext_convert[typ] or typ)
                    local ids_path = Idstring(path)
                    local file_path = Utils.Path:Combine(directory, path) .. "." .. typ
                    if SystemFS:exists(file_path) then
                        if (not DB:has(ids_ext, ids_path) or child.force) then
                            FileManager:AddFile(ids_ext, ids_path, file_path)
                            if child.reload then
                                PackageManager:reload(ids_ext, ids_path)
                            end
                            if child.load then
                                table.insert(loading, { ids_ext, ids_path, file_path })
                            end
                        end
                    else
                        BLT:LogF(LogLevel.ERROR, "PackageManager", "File '%s' does not exist!", tostring(file_path))
                    end
                else
                    BLT:LogF(LogLevel.ERROR, "PackageManager",
                        "Node in '%s' does not contain a definition for both type and path.", tostring(directory))
                end
            end
        end
    end
    --For some reason this needs to be here, instead of loading in the main loop or the game will go into a hissy fit
    for _, file in pairs(loading) do
        FileManager:LoadAsset(unpack(file))
    end
end

function C:UnloadPackageConfig(config)
    BLT:Log(LogLevel.INFO, "PackageManager", "Unloading added files")
    for i, child in ipairs(config) do
        if type(child) == "table" then
            local typ = child._meta
            local path = child.path
            if typ and path then
                path = Utils.Path:Normalize(path)
                local ids_ext = Idstring(self.ext_convert[typ] or typ)
                local ids_path = Idstring(path)
                if DB:has(ids_ext, ids_path) then
                    if child.unload ~= false then
                        FileManager:UnLoadAsset(ids_ext, ids_path)
                    end
                    FileManager:RemoveFile(ids_ext, ids_path)
                end
            elseif typ == "unit_load" or typ == "add" then
                self:UnloadPackageConfig(child)
            else
                BLT:Log(LogLevel.ERROR, "PackageManager",
                    "Some node does not contain a definition for both type and path.")
            end
        end
    end
end
