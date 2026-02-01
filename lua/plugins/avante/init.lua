local password_store_path = "gemini/avante"

local function setup_avante(api_key)
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
    behaviour = { auto_suggestions = false },
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
      local output = vim
        .system({ "pass", password_store_path }, {
          env = {
            PASSWORD_STORE_GPG_OPTS = "--passphrase-fd 0 --pinentry-mode loopback",
          },
          stdin = value,
          text = true,
        })
        :wait()
      if output.code == 0 then
        setup_avante(output.stdout)
        callback()
      else
        vim.notify("Can't unlock password store", vim.log.levels.ERROR)
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
      local check_key_output = vim
        .system({ "pass", password_store_path }, {
          env = { PASSWORD_STORE_GPG_OPTS = "--pinentry-mode cancel" },
          text = true,
        })
        :wait()
      if check_key_output.code == 0 then
        setup_avante(check_key_output.stdout)
      else
        prompt_and_setup_avante(function()
          require("avante.api").ask()
        end)
      end
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
