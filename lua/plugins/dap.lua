return {
  { "mfussenegger/nvim-dap" },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
        codelldb = function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      {
        "<leader>br",
        mode = { "n" },
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle dap-ui",
      },
      {
        "<leader>db",
        mode = { "n" },
        function()
          local dap = require "dap"
          local ft = vim.bo.filetype
          if ft == "" then
            print "Filetype option is required to determine which dap configs are available"
            return
          end
          local configs = dap.configurations[ft]
          if configs == nil then
            print('Filetype "' .. ft .. '" has no dap configs')
            return
          end

          -- always use the first config, assuming you only have one per filetype
          local iter = pairs(configs)
          local _, mConfig = iter(configs)

          -- redraw to make ui selector disappear
          vim.api.nvim_command "redraw"

          if mConfig == nil then
            return
          end
          vim.ui.input({
            prompt = mConfig.name .. " - with args: ",
          }, function(input)
            if input == nil then
              return
            end
            local args = vim.split(input, " ")
            mConfig.args = args
            dap.run(mConfig)
          end)
        end,
        desc = "Start debugger",
      },
      {
        "<leader>dt",
        mode = { "n" },
        function()
          require("dap").terminate()
        end,
        desc = "Terminate debugger",
      },
    },

    init = function()
      local color_utils = require "utils.colors"
      color_utils.register_color_update(function()
        vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
        vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
        vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })
      end)
      vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapLogPoint", { text = " ", texthl = "DapLogPoint" })
      vim.fn.sign_define("DapStopped", { text = " ", texthl = "DapStopped" })
    end,

    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        disabled_filetypes = {
          statusline = {
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
            "dap-repl",
          },
        },
      },
    },
    opts_extend = { "options.disabled_filetypes.statusline" },
  },
}
