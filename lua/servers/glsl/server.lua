local docs = require 'core.docs.registry'
local lsp = require 'core.lsp.registry'
local lint = require 'core.linter.registry'
local deps = require 'core.lang.registry'
local lang_name = require('utils.helpers').get_this_directory_name()
local GLSLANG_LINTER_NAME = 'glslang'
local DEFAULT_SHADER_STAGE = 'frag'
local GLSLANG_MESSAGE_PATTERN = '(%u+): %d+:(%d+): ([^\n]+)'
local GLSLANG_TERMINATION_MESSAGE = 'compilation terminated'
---@type string[]
local SHADER_STAGES = { 'vert', 'frag', 'comp', 'geom', 'tesc', 'tese' }
---@type table<string, string>
local GLSLANG_SEVERITIES = {
  ERROR = 'ERROR',
  WARNING = 'WARN',
}
local GHOSTTY_SHADER_PRELUDE = table.concat({
  '#version 430 core',
  'uniform sampler2D iChannel0;',
  'uniform vec3 iResolution;',
  'uniform float iTime;',
  'uniform float iTimeDelta;',
  'uniform float iFrameRate;',
  'uniform int iFrame;',
  'uniform float iChannelTime[4];',
  'uniform vec3 iChannelResolution[4];',
  'uniform vec4 iMouse;',
  'uniform vec4 iDate;',
  'uniform float iSampleRate;',
  'uniform vec4 iCurrentCursor;',
  'uniform vec4 iPreviousCursor;',
  'uniform vec4 iCurrentCursorColor;',
  'uniform vec4 iPreviousCursorColor;',
  'uniform vec4 iCurrentCursorStyle;',
  'uniform vec4 iPreviousCursorStyle;',
  'uniform vec4 iCursorVisible;',
  'uniform float iTimeCursorChange;',
  'uniform float iTimeFocus;',
  'uniform int iFocus;',
  'uniform vec3 iPalette[256];',
  'uniform vec3 iBackgroundColor;',
  'uniform vec3 iForegroundColor;',
  'uniform vec3 iCursorColor;',
  'uniform vec3 iCursorText;',
  'uniform vec3 iSelectionBackgroundColor;',
  'uniform vec3 iSelectionForegroundColor;',
  '#define CURSORSTYLE_BLOCK 0',
  '#define CURSORSTYLE_BLOCK_HOLLOW 1',
  '#define CURSORSTYLE_BAR 2',
  '#define CURSORSTYLE_UNDERLINE 3',
  '#define CURSORSTYLE_LOCK 4',
  '#line 1',
  '',
}, '\n')

---@return boolean
local function current_buffer_declares_version()
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match '^%s*#version' then return true end
  end
  return false
end

---@return string
local function get_current_buffer_shader_stage()
  local extension = vim.fn.expand '%:e'
  return vim.list_contains(SHADER_STAGES, extension) and extension
    or DEFAULT_SHADER_STAGE
end

---@return string
local function get_shader_prelude()
  return current_buffer_declares_version() and '' or GHOSTTY_SHADER_PRELUDE
end

---@param output string
---@return vim.Diagnostic[]
local function parse_glslang_output(output)
  ---@type vim.Diagnostic[]
  local diagnostics = {}
  for severity, line_number, message in output:gmatch(GLSLANG_MESSAGE_PATTERN) do
    if not message:find(GLSLANG_TERMINATION_MESSAGE, 1, true) then
      table.insert(diagnostics, {
        lnum = math.max(tonumber(line_number) - 1, 0),
        col = 0,
        severity = vim.diagnostic.severity[GLSLANG_SEVERITIES[severity] or 'INFO'],
        message = message,
        source = GLSLANG_LINTER_NAME,
      })
    end
  end
  return diagnostics
end

docs.docs_ignore()

deps.record_toolchain {}

lint.record_linter {
  linter = GLSLANG_LINTER_NAME,
  deps = { { cmd = 'glslangValidator', install_command = 'glslang' } },
  config = {
    name = GLSLANG_LINTER_NAME,
    cmd = 'sh',
    stdin = true,
    ignore_exitcode = true,
    stream = 'stdout',
    args = {
      '-c',
      '{ printf "%s" "$1"; cat; } | glslangValidator --stdin -S "$2"',
      GLSLANG_LINTER_NAME,
      get_shader_prelude,
      get_current_buffer_shader_stage,
    },
    parser = parse_glslang_output,
  },
}

lsp.record_lsp {
  deps = { { install_command = 'glsl_analyzer-bin' } },
  cmd = { 'glsl_analyzer' },
  filetypes = {
    lang_name,
    'vert',
    'frag',
    'comp',
    'geom',
    'tesc',
    'tese',
  },
  root_markers = { '.git' },
}
