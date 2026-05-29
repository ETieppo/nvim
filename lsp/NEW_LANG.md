Binário → adiciona o nome do pacote em ensure_installed no mason.lua.
LSP liga → adiciona o nome (lspconfig) em vim.lsp.enable {...}.
LSP ajusta (opcional) → só se precisar mudar settings/root: cria ~/.config/nvim/lsp/<servidor>.lua. Na maioria dos casos você nem precisa.
Treesitter → adiciona o parser na lista do tree-sitter.lua.
Formatter (se tiver) → adiciona em formatters_by_ft no autoformat.lua.
Linter (se tiver) → adiciona em linters_by_ft no lint.lua.
