
---@class MaterialIconProps
---@field icon string
---@field color string
---@field name string

local DEFAULT_FILE_ICON_KEY = 'file'
local ICON_PADDING = ' '
---@type table<string, MaterialIconProps>|nil
local padded_icons = nil

---@type table<string, string>
local custom_file_names = {
  ['.bash_aliases'] = 'console',
  ['.bash_history'] = 'console',
  ['.bash_logout'] = 'console',
  ['.bash_profile'] = 'console',
  ['.bashrc'] = 'console',
  ['.env'] = 'tune',
  ['.profile'] = 'console',
  ['.xcode.env'] = 'tune',
  ['.xcode.env.local'] = 'tune',
  ['.zlogin'] = 'console',
  ['.zlogout'] = 'console',
  ['.zprofile'] = 'console',
  ['.zsh_history'] = 'console',
  ['.zshenv'] = 'console',
  ['.zshrc'] = 'console',
}

---@param icons_to_pad table<string, MaterialIconProps>
local function pad_icons(icons_to_pad)
  for _, icon_to_pad in pairs(icons_to_pad) do
    if not vim.endswith(icon_to_pad.icon, ICON_PADDING) then
      icon_to_pad.icon = icon_to_pad.icon .. ICON_PADDING
    end
  end
end

local M = {}

---@return table<string, MaterialIconProps>
local function get_icons()
  if padded_icons then return padded_icons end
  padded_icons = require 'layout.icons.data.override'
  pad_icons(padded_icons)
  return padded_icons
end

---@param icon_keys table<string, string>
---@return table<string, MaterialIconProps>
local function resolve_icons(icon_keys)
  ---@type table<string, MaterialIconProps>
  local resolved_icons = {}
  local icons = get_icons()
  for name, icon_key in pairs(icon_keys) do
    resolved_icons[name] = icons[icon_key]
  end
  return resolved_icons
end

---@return table<string, MaterialIconProps>
function M.get_icons_by_extension()
  return vim.tbl_extend(
    'keep',
    resolve_icons(require 'layout.icons.data.file_extensions'),
    resolve_icons(require 'layout.icons.data.language_ids')
  )
end

---@return table<string, MaterialIconProps>
function M.get_icons_by_filename()
  return resolve_icons(
    vim.tbl_extend(
      'force',
      require 'layout.icons.data.file_names',
      custom_file_names
    )
  )
end

---@return MaterialIconProps
function M.get_default_file_icon() return get_icons()[DEFAULT_FILE_ICON_KEY] end

M.pad_icons = pad_icons

return M
