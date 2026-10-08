local test_adapters = require('utils.lang').test_adapters

local deps = {
  'nvim-neotest/nvim-nio',
  'nvim-lua/plenary.nvim',
  'nvim-treesitter/nvim-treesitter',
  'antoinemadec/FixCursorHold.nvim',
}

for _, a in ipairs(test_adapters) do
  table.insert(deps, a[1])
end

return {
  'nvim-neotest/neotest',
  dependencies = deps,
  opts = function()
    local adapters = {}
    for _, a in ipairs(test_adapters) do
      local ok, adapter = pcall(require, a.module)
      if ok then
        if a.opts then adapter = adapter(a.opts) end
        table.insert(adapters, adapter)
      else
        vim.notify(
          'neotest: no adapter was found' .. a.module,
          vim.log.levels.WARN
        )
      end
    end

    return {
      adapters = adapters,
      consumers = {
        auto_open = function(client)
          client.listeners.run = function()
            vim.schedule(function()
              local win = vim.api.nvim_get_current_win()
              require('neotest').summary.open()
              require('neotest').output_panel.open()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
              end
            end)
          end
          return {}
        end,
      },
    }
  end,
}
