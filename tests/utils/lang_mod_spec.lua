local helpers = require 'utils.helpers'
local stub = require 'luassert.stub'
local lang_mod = require 'utils.lang_mod'

local fixture_path = vim.fn.fnamemodify(
  debug.getinfo(1, 'S').source:sub(2),
  ':p:h:h'
) .. '/fixtures/fixture_lang.lua'

describe('helpers', function()
  it(
    'returns the current file name',
    function() assert.are.equal('lang_mod_spec', helpers.get_this_filename()) end
  )

  it('returns the caller file name', function()
    local function record()
      local name = helpers.get_caller_filename()
      return name
    end
    local name = record()
    assert.are.equal('lang_mod_spec', name)
  end)
end)

describe('lang_mod records', function()
  dofile(fixture_path)
  dofile(fixture_path)

  it('infers the lang name from the calling file', function()
    local lang = lang_mod.langs.fixture_lang
    assert.are.equal('fixture_lang', lang.lang)
    assert.are.equal('fx', lang.short)
  end)

  it(
    'tags each dep with the lang that records it',
    function()
      assert.are.equal('fixture_lang', lang_mod.langs.fixture_lang.deps[1].lang)
    end
  )

  it(
    'finds a lang by its short name',
    function() assert.are.equal('fixture_lang', lang_mod.find_lang('fx').lang) end
  )

  it('infers the lang for formatters and linters', function()
    assert.are.same({ 'fixture_fmt' }, lang_mod.formatters.linkers.fixture_lang)
    assert.are.same({ 'fixture_lint' }, lang_mod.linters.fixture_lang)
  end)

  it(
    'keeps an explicit lang override',
    function()
      assert.are.same(
        { 'override_fmt' },
        lang_mod.formatters.linkers.fixture_override
      )
    end
  )

  it('respects ignored treesitters and avoids duplicates', function()
    assert.is_false(
      vim.list_contains(lang_mod.install_lang_treesitters, 'fixture_lang')
    )
    assert.are.same({ 'fixture_lang' }, lang_mod.ignore_at_treesitter)
  end)
end)

describe('lang_mod dap and docs records', function()
  it('infers the lang and default filetypes for dap', function()
    local record = lang_mod.dap.configurations.fixture_lang
    assert.are.equal('fixture_adapter', record.adapter)
    assert.are.same({ 'fixture_lang' }, record.filetypes)
  end)

  it('collects unique sorted docs', function()
    lang_mod.record_docs {
      lang = 'fixture_other',
      docs = { 'a_doc', 'fixture_doc' },
    }
    local docs = lang_mod.get_docs()
    assert.are.same({ 'a_doc', 'fixture_doc' }, docs)
  end)
end)

describe('lang_mod.resolve_lang_deps', function()
  local rustup = { cmd = 'fake-rustup' }
  local cargo = { cmd = 'fake-cargo' }
  local analyzer = { cmd = 'fake-analyzer' }
  local bun = { cmd = 'fake-bun' }

  lang_mod.record_lang_deps {
    lang = 'fake_rust',
    short = 'frs',
    deps = { rustup, cargo, analyzer },
  }
  lang_mod.record_lang_deps { lang = 'fake_ts', deps = { bun } }

  ---@param deps DepProps[]
  ---@return string[]
  local function cmds(deps)
    return vim.tbl_map(function(dep) return dep.cmd end, deps)
  end

  it('expands a lang reference into all its deps', function()
    lang_mod.record_lang_deps {
      lang = 'fake_wgsl',
      deps = { { cmd = 'fake-fmt', depends_on = 'fake_rust' } },
    }
    local resolution = lang_mod.resolve_lang_deps(lang_mod.langs.fake_wgsl)
    assert.are.same(
      { 'fake-rustup', 'fake-cargo', 'fake-analyzer', 'fake-fmt' },
      cmds(resolution.deps)
    )
  end)

  it('expands a cmd reference up to that cmd', function()
    lang_mod.record_lang_deps {
      lang = 'fake_wgsl',
      deps = { { cmd = 'fake-fmt', depends_on = 'fake-cargo' } },
    }
    local resolution = lang_mod.resolve_lang_deps(lang_mod.langs.fake_wgsl)
    assert.are.same(
      { 'fake-rustup', 'fake-cargo', 'fake-fmt' },
      cmds(resolution.deps)
    )
  end)

  it('resolves lang level references and short names', function()
    lang_mod.record_lang_deps {
      lang = 'fake_game',
      depends_on = 'frs',
      deps = { { cmd = 'fake-bun-pkg', depends_on = 'fake-bun' } },
    }
    local resolution = lang_mod.resolve_lang_deps(lang_mod.langs.fake_game)
    assert.are.same({
      'fake-rustup',
      'fake-cargo',
      'fake-analyzer',
      'fake-bun',
      'fake-bun-pkg',
    }, cmds(resolution.deps))
  end)

  it('does not loop on cyclic references', function()
    lang_mod.record_lang_deps {
      lang = 'fake_cycle_a',
      depends_on = 'fake_cycle_b',
      deps = { { cmd = 'fake-a' } },
    }
    lang_mod.record_lang_deps {
      lang = 'fake_cycle_b',
      depends_on = 'fake_cycle_a',
      deps = { { cmd = 'fake-b' } },
    }
    local resolution = lang_mod.resolve_lang_deps(lang_mod.langs.fake_cycle_a)
    assert.are.same({ 'fake-b', 'fake-a' }, cmds(resolution.deps))
  end)

  it('reports unknown references', function()
    lang_mod.record_lang_deps {
      lang = 'fake_unknown',
      deps = { { cmd = 'fake-x', depends_on = 'does-not-exist' } },
    }
    local resolution = lang_mod.resolve_lang_deps(lang_mod.langs.fake_unknown)
    assert.are.same({ 'does-not-exist' }, resolution.unresolved_references)
    assert.are.same({ 'fake-x' }, cmds(resolution.deps))
  end)
end)

describe('lang_mod.warn_missing_lang_deps', function()
  local messages = {}
  local notify = stub(
    vim,
    'notify',
    function(message, level)
      table.insert(messages, { message = message, level = level })
    end
  )

  before_each(function() messages = {} end)

  it('warns once per lang for a matching filetype', function()
    lang_mod.record_lang_deps {
      lang = 'fake_warn',
      short = 'fw',
      deps = { { cmd = 'sh' }, { cmd = 'definitely-missing-cli' } },
    }
    local buffer = vim.api.nvim_create_buf(false, true)

    lang_mod.warn_missing_lang_deps('fake_warn', buffer)
    lang_mod.warn_missing_lang_deps('fake_warn', buffer)

    assert.are.equal(1, #messages)
    assert.are.equal(vim.log.levels.WARN, messages[1].level)
    assert.is_truthy(
      messages[1].message:find('definitely-missing-cli', 1, true)
    )
    assert.is_truthy(messages[1].message:find(':Lang i fw', 1, true))
  end)

  it('stays silent when every dep exists', function()
    lang_mod.record_lang_deps { lang = 'fake_ok', deps = { { cmd = 'sh' } } }
    lang_mod.warn_missing_lang_deps(
      'fake_ok',
      vim.api.nvim_create_buf(false, true)
    )
    assert.are.equal(0, #messages)
  end)

  it('matches langs through their lsp filetypes', function()
    vim.lsp.config('fake_lsp_lang', { filetypes = { 'fake_ft' } })
    lang_mod.record_lang_deps {
      lang = 'fake_lsp_lang',
      deps = { { cmd = 'definitely-missing-cli' } },
    }
    lang_mod.warn_missing_lang_deps(
      'fake_ft',
      vim.api.nvim_create_buf(false, true)
    )
    assert.are.equal(1, #messages)
  end)

  it('skips workspace langs outside their workspace', function()
    vim.lsp.config('fake_workspace_lang', {
      filetypes = { 'fake_ws_ft' },
      workspace_required = true,
      root_markers = { 'definitely-missing-marker.json' },
    })
    lang_mod.record_lang_deps {
      lang = 'fake_workspace_lang',
      deps = { { cmd = 'definitely-missing-cli' } },
    }
    lang_mod.warn_missing_lang_deps(
      'fake_ws_ft',
      vim.api.nvim_create_buf(false, true)
    )
    assert.are.equal(0, #messages)
  end)

  notify:revert()
end)
