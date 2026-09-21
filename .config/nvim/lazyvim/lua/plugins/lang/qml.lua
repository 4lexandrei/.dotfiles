return {
  {
    vim.lsp.config("qmlls", {
      cmd = { "qmlls6" },
    }),
    vim.lsp.enable("qmlls"),
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        qml = { "qmlformat" },
      })
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        qmlformat = {
          command = "/usr/lib/qt6/bin/qmlformat",
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "qmljs",
      })
    end,
  },
}
