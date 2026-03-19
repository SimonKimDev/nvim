-- ~/.config/nvim/lua/simonkdev/lazy/formatting.lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>mp",
      function()
        require("conform").format({
          lsp_fallback = true,  -- use LSP formatter
          async = false,
          timeout_ms = 8000,
        })
      end,
      mode = { "n", "v" },
      desc = "Format file or range",
    },
  },

  opts = {
    -- Only map C# to LSP formatter. No external tools.
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      lua = { "stylua" },
      go = { "gofmt" },
    },

    -- On-save formatting via LSP
    format_on_save = {
      lsp_fallback = true,  -- for C#, this means Roslyn LSP (csharp_ls)
      async = false,
      timeout_ms = 8000,
    },
  },
}

