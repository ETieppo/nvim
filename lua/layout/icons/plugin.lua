local plugins = require 'deps.plugins'
local material_icons = require 'layout.icons.loader'

local type_colors = {
  { file_type = 'adapter', color = '#8D6E63' },
  { file_type = 'component', color = '#1976D3' },
  { file_type = 'consumer', color = '#80CBC4' },
  { file_type = 'controller', color = '#42A5F5' },
  { file_type = 'decorator', color = '#C0CA33' },
  { file_type = 'directive', color = '#AB48BC' },
  { file_type = 'dto', color = '#9CCC65' },
  { file_type = 'entity', color = '#BCAAA4' },
  { file_type = 'event', color = '#F06292' },
  { file_type = 'exception', color = '#FF8A80' },
  { file_type = 'filter', color = '#26C6DA' },
  { file_type = 'gateway', color = '#5C6BC0' },
  { file_type = 'guard', color = '#44A047' },
  { file_type = 'interceptor', color = '#26A69A' },
  { file_type = 'interface', color = '#90A4AE' },
  { file_type = 'listener', color = '#F48FB1' },
  { file_type = 'middleware', color = '#7E57C2' },
  { file_type = 'module', color = '#E63936' },
  { file_type = 'mod', color = '#E63936' },
  { file_type = 'pipe', color = '#FF7043' },
  { file_type = 'processor', color = '#FFB74D' },
  { file_type = 'provider', color = '#FFE082' },
  { file_type = 'repository', color = '#78909C' },
  { file_type = 'resolver', color = '#FFC0CB' },
  { file_type = 'schema', color = '#A1887F' },
  { file_type = 'service', color = '#FFCA29' },
  { file_type = 'strategy', color = '#66BB6A' },
  { file_type = 'subscriber', color = '#4DD0E1' },
}

local apply_langs = {
  { suffix = 'rs', icon_prefix = 'Rust', icon = '\u{E68B}' },
  { suffix = 'ts', icon_prefix = 'Nest', icon = '\u{E83B}' },
}

local function build_language_icons()
  ---@type table<string, MaterialIconProps>
  local icons = {}
  for _, lang in ipairs(apply_langs) do
    for _, type_color in ipairs(type_colors) do
      local file_type = type_color.file_type
      icons[file_type .. '.' .. lang.suffix] = {
        icon = lang.icon,
        color = type_color.color,
        name = lang.icon_prefix .. file_type:gsub('^%l', string.upper),
      }
    end
  end
  return icons
end

local custom_icons = {
  default_icon = material_icons.get_default_file_icon(),
  tl = {
    icon = '\u{F08B1}',
    color = '#00B1BC',
    name = 'Teal',
  },
  kof = {
    icon = '\u{F0B12}',
    color = '#FFFFFF',
    name = 'Kf',
  },
  kf = {
    icon = '\u{F0B12}',
    color = '#FFFFFF',
    name = 'Kof',
  },
  ['ng-template'] = {
    icon = '\u{E83B}',
    color = '#E63936',
    name = 'NestTemplate',
  },
}

plugins.record {
  'DaikyXendo/nvim-material-icon',
  enabled = vim.g.have_nerd_font,
  config = function(_, opts)
    local devicons = require 'nvim-web-devicons'
    devicons.setup(opts)
    material_icons.pad_icons(devicons.get_icons())
    material_icons.pad_icons(devicons.get_icons_by_filename())
    material_icons.pad_icons(devicons.get_icons_by_extension())
  end,
  opts = {
    default = true,
    color_icons = true,
    override = custom_icons,
    override_by_filename = material_icons.get_icons_by_filename(),
    override_by_extension = vim.tbl_extend(
      'force',
      build_language_icons(),
      material_icons.get_icons_by_extension(),
      custom_icons
    ),
  },
}
