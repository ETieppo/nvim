local default_icons = require 'layout.material_icons.data.default_icons'
local file_extensions = require 'layout.material_icons.data.file_extensions'
local file_names = require 'layout.material_icons.data.file_names'
local folder_names = require 'layout.material_icons.data.folder_names'
local folder_open_icons = require 'layout.material_icons.data.folder_open_icons'
local icons = require 'layout.material_icons.data.icons'
local language_ids = require 'layout.material_icons.data.language_ids'

---@class MaterialIconProps
---@field icon string
---@field color string
---@field name string

---@type table<string, string>
local custom_folder_names = {
  authorization = 'folder-secure',
  cors = 'folder-secure',
  deps = 'folder-packages',
  dto = 'folder-interface',
  dtos = 'folder-interface',
  entities = 'folder-class',
  gateways = 'folder-api',
  workflows = 'folder-github',
}

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

local ICON_PADDING = ' '

---@param icons_to_pad table<string, MaterialIconProps>
local function pad_icons(icons_to_pad)
  for _, icon_to_pad in pairs(icons_to_pad) do
    if not vim.endswith(icon_to_pad.icon, ICON_PADDING) then
      icon_to_pad.icon = icon_to_pad.icon .. ICON_PADDING
    end
  end
end

pad_icons(icons)

local M = {}

---@param icon_keys table<string, string>
---@return table<string, MaterialIconProps>
local function resolve_icons(icon_keys)
  ---@type table<string, MaterialIconProps>
  local resolved_icons = {}
  for name, icon_key in pairs(icon_keys) do
    resolved_icons[name] = icons[icon_key]
  end
  return resolved_icons
end

local function define_folder_highlights()
  for _, material_icon in pairs(icons) do
    vim.api.nvim_set_hl(
      0,
      'DevIcon' .. material_icon.name,
      { fg = material_icon.color }
    )
  end
end

---@param name string
---@return string
local function normalize_folder_name(name)
  local normalized_name = name:lower():gsub('^[._-]+', ''):gsub('_+$', '')
  return normalized_name
end

---@param folder_name string
---@return string?
local function find_closed_icon_key(folder_name)
  local normalized_name = normalize_folder_name(folder_name)
  return custom_folder_names[normalized_name] or folder_names[normalized_name]
end

function M.setup()
  define_folder_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('MaterialFolderHighlights', {}),
    callback = define_folder_highlights,
  })
end

---@return table<string, MaterialIconProps>
function M.get_icons_by_extension()
  return vim.tbl_extend(
    'keep',
    resolve_icons(file_extensions),
    resolve_icons(language_ids)
  )
end

---@return table<string, MaterialIconProps>
function M.get_icons_by_filename()
  return resolve_icons(vim.tbl_extend('force', file_names, custom_file_names))
end

---@return MaterialIconProps
function M.get_default_file_icon() return icons[default_icons.file] end

M.pad_icons = pad_icons

---@param icon table
---@param node table
function M.apply_folder_icon(icon, node)
  local closed_icon_key = find_closed_icon_key(node.name)
  if not closed_icon_key then
    icon.text = icon.text .. ICON_PADDING
    return
  end
  local icon_key = node:is_expanded() and folder_open_icons[closed_icon_key]
    or closed_icon_key
  local material_icon = icons[icon_key]
  icon.text = material_icon.icon
  icon.highlight = 'DevIcon' .. material_icon.name
end

return M
