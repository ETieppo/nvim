local lang_mod = require 'utils.lang_mod'

lang_mod.ignore_treesitter_install()

lang_mod.record_lang_deps {
  short = 'fx',
  deps = { { cmd = 'fixture-cli' } },
}

lang_mod.record_fmt { formatter = 'fixture_fmt' }

lang_mod.record_linter { linter = 'fixture_lint' }

lang_mod.record_fmt { lang = 'fixture_override', formatter = 'override_fmt' }

lang_mod.record_dap {
  adapter = 'fixture_adapter',
  configurations = { { name = 'Fixture launch' } },
}

lang_mod.record_docs { docs = { 'fixture_doc' } }
