---@meta SGG_Modding-Chalk
local chalk = {}

-- TODO: define all the other public functions

--[[
          Loads the more recent (by version) of a `.cfg` file and a lua table, and updates the `.cfg` file accordingly (replacing vs. merging entries recursively).
]]
---@param path string name of (or path to) the config file to keep updated
---@param default? table lua config table to use as a default
---@param descript? table<any,string> recursive table of descriptions of the keys in the config
---@param section? string the name of the root section of the resulting `.cfg` file
---@param is_newer? fun(a: table, b:table): b_newer_than_a: boolean compares the current config to the default to determine which is newer
---@return table wrapper a table-like wrapper around the config system
---@return table config the actual config object
function chalk.load(path,default,descript,section,is_newer) end
---@alias SGG_Modding-Chalk.load ...

--[[
          Loads the more recent (by version) of *your plugin's* `config.cfg` and `config.lua`, and updates the `config.cfg` accordingly (replacing vs. merging entries recursively).
]]
---@param config_lua? string name of (or path to) the `lua` config file to use as a default
---@param config_cfg? string name of (or path to) the `cfg` config file to keep updated
---@param descript? table<any,string> recursive table of descriptions of the keys in the config
---@param section? string the name of the root section of the resulting `.cfg` file
---@param is_newer? fun(a: table, b:table): b_newer_than_a: boolean compares the current config to the default to determine which is newer
---@return table wrapper a table-like wrapper around the config system
---@return table config the actual config object
function chalk.auto(config_lua,config_cfg,descript,section,is_newer) end
---@alias SGG_Modding-Chalk.auto ...

return chalk