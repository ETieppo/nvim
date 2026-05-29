local mason = vim.fn.stdpath 'data' .. '/mason/packages'
local angular_pkg = mason .. '/angular-language-server/node_modules/@angular/language-server'
local ts_lib = mason .. '/angular-language-server/node_modules/typescript/lib'

return {
  cmd = { 'ngserver', '--stdio', '--tsProbeLocations', ts_lib, '--ngProbeLocations', angular_pkg },
  filetypes = { 'html', 'htmlangular' },
  root_markers = { 'angular.json' },
}
