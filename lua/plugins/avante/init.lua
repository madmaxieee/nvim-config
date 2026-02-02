---@param api_key string
local function setup_avante(api_key)
  api_key = vim.trim(api_key)
  local api_key_cmd = { "echo", api_key }
  require("avante").setup({
    provider = "gemini",
    providers = {
      gemini = {
        model = "gemini-3-pro-preview",
        api_key_name = api_key_cmd,
      },
      gemini_flash = {
        __inherited_from = "gemini",
        model = "gemini-3-flash-preview",
        api_key_name = api_key_cmd,
      },
    },
    repo_map = {
      ignore_patterns = {
        "%.git",
        "%.worktree",
        "__pycache__",
        "node_modules",
        "%.jj",
        "%.hg",
      },
    },
    selection = {
      enabled = true,
      hint_display = "none",
    },
    input = {
      provider = "snacks",
      provider_opts = {
        title = "Avante Input",
        icon = " ",
      },
    },
    mappings = {
      diff = {
        next = "]h",
        prev = "[h",
      },
    },
  })
  vim.g.avante_loaded = true
end

---@param callback? function
local function prompt_and_setup_avante(callback)
  if vim.g.avante_loaded then
    return
  end

  local SecretInput = require("plugins.avante.secret_input")
  local event = require("nui.utils.autocmd").event

  local input = SecretInput({
    relative = "editor",
    position = "50%",
    size = { width = 40 },
    border = {
      style = "rounded",
      text = {
        top = "[unlock password store]",
        top_align = "center",
      },
    },
  }, {
    on_submit = function(value)
      ---@param res vim.SystemCompleted
      local function on_exit(res)
        if res.code == 0 then
          setup_avante(res.stdout)
          if callback then
            callback()
          end
        else
          vim.notify("Can't unlock password store", vim.log.levels.ERROR)
        end
      end
      if vim.fn.executable("op") == 1 then
        vim.system({ "op", "read", "op://google/gemini/credential" }, on_exit)
      else
        vim.system({ "pass", "gemini/cli" }, {
          env = {
            PASSWORD_STORE_GPG_OPTS = "--passphrase-fd 0 --pinentry-mode loopback",
          },
          stdin = value,
        }, on_exit)
      end
    end,
  })

  input:mount()

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })

  input:on(event.BufLeave, function()
    input:unmount()
  end)
end

return {
  {
    "yetone/avante.nvim",
    build = "make",
    event = { "VeryLazy" },
    keys = {
      {
        "<leader>aa",
        mode = "n",
        function()
          if vim.g.avante_loaded then
            require("avante.api").ask()
          else
            prompt_and_setup_avante(require("avante.api").ask)
          end
        end,
        desc = "avante ask",
      },
      {
        "<leader>ae",
        mode = "v",
        function()
          if vim.g.avante_loaded then
            require("avante.api").edit()
          else
            prompt_and_setup_avante(require("avante.api").edit)
          end
        end,
        desc = "avante edit",
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "Avante" } },
        ft = { "Avante" },
      },
    },

    config = function()
      vim.system({ "pass", "gemini/cli" }, {
        env = { PASSWORD_STORE_GPG_OPTS = "--pinentry-mode cancel" },
        text = true,
      }, function(out)
        if out.code == 0 then
          vim.schedule(function()
            setup_avante(out.stdout)
          end)
        else
          vim.vim.api.nvim_create_user_command("AvanteLoad", function()
            prompt_and_setup_avante()
          end, {
            nargs = 0,
            desc = "Load Avante API key from password store",
          })
        end
      end)
    end,
  },

  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = {
          "avante_commands",
          "avante_mentions",
          "avante_shortcuts",
          "avante_files",
        },
        providers = {
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
          avante_shortcuts = {
            name = "avante_shortcuts",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        disabled_filetypes = {
          statusline = {
            "Avante",
            "AvanteSelectedFiles",
          },
        },
      },
    },
    opts_extend = { "options.disabled_filetypes.statusline" },
  },
}
