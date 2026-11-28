local TERRAFORM = 'terraform'

---@type LangDefProps
return {
  short = 'tf',
  filetypes = { TERRAFORM, 'tf', 'terraform-vars' },
  treesitter = TERRAFORM,
  doc = { 'opentofu' },
  deps = { { cmd = 'tofu', install_command = 'opentofu' } },
  filetype_rules = {
    extension = {
      tofu = TERRAFORM,
    },
  },
  TERRAFORM = TERRAFORM,
}
