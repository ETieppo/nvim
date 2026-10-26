local os_mod = require 'utils.os_mod'
local ArchiveFormatEnum = require 'utils.enums.archive_format_enum'

---@class ReleaseAdapterWrapperProps
---@field runtime string
---@field entry string

---@class ReleaseAdapterProps
---@field name string
---@field repo string
---@field asset_pattern string
---@field archive_format ArchiveFormatEnum
---@field bin_subdir? string
---@field wrapper? ReleaseAdapterWrapperProps
---@field install_root? string

---@class ReleaseAdapter : ReleaseAdapterProps
local ReleaseAdapter = {}
ReleaseAdapter.__index = ReleaseAdapter

---@type table<ArchiveFormatEnum, string>
local extract_commands = {
  [ArchiveFormatEnum.tar_gz] = 'tar -xzf "$dir/asset" -C "$dir"',
  [ArchiveFormatEnum.zip] = 'unzip -q "$dir/asset" -d "$dir"',
}

---@param props ReleaseAdapterProps
---@return ReleaseAdapter
function ReleaseAdapter.new(props)
  return setmetatable(vim.deepcopy(props), ReleaseAdapter)
end

---@return string
function ReleaseAdapter:get_install_dir()
  local install_root = self.install_root
    or vim.fn.stdpath 'data' .. '/debug-adapters'
  return install_root .. '/' .. self.name
end

---@return string
function ReleaseAdapter:get_bin_dir()
  return self:get_install_dir() .. '/' .. (self.bin_subdir or 'bin')
end

---@return string[]
function ReleaseAdapter:build_wrapper_steps()
  if not self.wrapper then return {} end

  local wrapper_path = '"$dir/bin/' .. self.name .. '"'
  return {
    'mkdir -p "$dir/bin"',
    ('printf \'#!/bin/sh\\nexec %s "%%s" "$@"\\n\' "$dir/%s" > %s'):format(
      self.wrapper.runtime,
      self.wrapper.entry,
      wrapper_path
    ),
    'chmod +x ' .. wrapper_path,
  }
end

---@return string
function ReleaseAdapter:build_install_command()
  local steps = {
    ("dir='%s'"):format(self:get_install_dir()),
    ("url=$(curl -fsSL https://api.github.com/repos/%s/releases/latest | grep -oE 'https://[^\"]+%s' | head -n 1)"):format(
      self.repo,
      self.asset_pattern
    ),
    'test -n "$url"',
    'rm -rf "$dir"',
    'mkdir -p "$dir"',
    'curl -fsSL -o "$dir/asset" "$url"',
    extract_commands[self.archive_format],
    'rm "$dir/asset"',
  }
  vim.list_extend(steps, self:build_wrapper_steps())
  return table.concat(steps, ' && ')
end

---@return boolean
function ReleaseAdapter:add_to_path()
  vim.fn.mkdir(self:get_bin_dir(), 'p')
  return os_mod.add_to_path(self:get_bin_dir())
end

return ReleaseAdapter
