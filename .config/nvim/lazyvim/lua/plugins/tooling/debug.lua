-- NOTE: Experimental do not push yet
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      -- "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local util = require("lspconfig.util")
      local root = util.root_pattern(
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja"
      )(vim.fn.getcwd()) or util.root_pattern("compile_commands.json", "compile_flags.txt")(vim.fn.getcwd()) or vim.fn.getcwd()
      local build_dir = root .. "/build"
      local cwd
      if vim.fn.isdirectory(build_dir) == 1 then
        cwd = build_dir
      else
        cwd = root
      end

      -- dapui
      dapui.setup()
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.after.terminate.dapui_config = function()
        dapui.close()
      end

      -- dap
      dap.adapters.gdb = {
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        type = "executable",
      }

      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", cwd .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          -- cwd = cwd,
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = "Attach to process",
          type = "gdb",
          request = "attach",
          pid = function()
            local name = vim.fn.input("Executable name (filter): ")
            return require("dap.utils").pick_process({ filter = name })
          end,
          cwd = "${workspaceFolder}",
          -- cwd = cwd,
        },
      }

      -- Keymaps
      vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_over)
      vim.keymap.set("n", "<F3>", dap.step_into)
      vim.keymap.set("n", "<F4>", dap.step_out)
    end,
  },
}
