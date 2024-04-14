LocalizationManager._custom_localizations = LocalizationManager._custom_localizations or {}
Hooks:RegisterHook("LocalizationManagerPostInit")
Hooks:Post(LocalizationManager, "init", "BLT.LocalizationManager.Init", function(self, ...)
	Hooks:Call("LocalizationManagerPostInit", self, ...)
end)

LocalizationManager._orig_text = LocalizationManager._orig_text or LocalizationManager.text
function LocalizationManager:text(str, macros, ...)
	if self._custom_localizations[str] then
		local return_str = self._custom_localizations[str]
		local i, j = return_str:find("$([^%s;]+)")
		if i then
			-- If the first macro is not using a trailing semicolon, then log the string. Checking
			-- all macros would be a performance waste.
			if return_str:byte(j + 1) ~= 59 then
				BLT:Log(LogLevel.WARN, "BLTLocalization",
					debug.traceback("The use of macros without a trailing semicolon is deprecated in " .. tostring(str)))
			end

			-- Look for macros defined as either $FORMAT or $FORMAT; (i.e. make the trailing semicolon optional)
			if type(macros) == "table" then
				return_str = return_str:gsub("$([^%s;]+);?", macros)
			end

			-- Handle default macros with the same format rules
			if self._default_macros ~= nil then
				return_str = return_str:gsub("$([^;%s]+);?", self._default_macros)
			end
		end
		return return_str
	end
	return self:_orig_text(str, macros, ...)
end

function LocalizationManager:add_localized_strings(string_table, overwrite)
	-- Should we overwrite existing localization strings
	if overwrite == nil then
		overwrite = true
	end

	if type(string_table) == "table" then
		for k, v in pairs(string_table) do
			if overwrite or not self._custom_localizations[k] then
				self._custom_localizations[k] = v
			end
		end
	end
end

function LocalizationManager:load_localization_file(file_path, overwrite)
	-- Should we overwrite existing localization strings
	if overwrite == nil then
		overwrite = true
	end

	local file = io.open(file_path, "r")
	if file then
		local success, data = pcall(function() return json.decode(file:read("*all")) end)
		file:close()
		if success then
			self:add_localized_strings(data, overwrite)
			return true
		end
		BLT:LogF(LogLevel.ERROR, "BLTMenuHelper", "Failed parsing json file at path '%s': %s", file_path, data)
	end
	return false
end
