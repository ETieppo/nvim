return {
  'artemave/workspace-diagnostics.nvim',
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'ts_ls' then
          require('workspace-diagnostics').populate_workspace_diagnostics(client, args.buf)
        end
      end,
    })
  end,
}
