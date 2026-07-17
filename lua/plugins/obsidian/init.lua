local vault_folder = vim.fn.resolve(vim.fn.expand("~/obsidian"))

---@type LazySpec
return {
  {
    cond = vim.startswith(vim.uv.cwd() or "", vault_folder),
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = {
      {
        "<leader>fo",
        "<cmd>Obsidian search<cr>",
        desc = "Obsidian search",
      },
    },

    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "notes",
          path = "~/obsidian/notes",
        },
      },
      picker = {
        name = "snacks.pick",
      },
    },

    init = function()
      vim.opt.conceallevel = 2
      vim.cmd.cabbrev("O", "Obsidian")
    end,

    config = function(_, opts)
      require("obsidian").setup(opts)
      require("plugins.obsidian.config").setup_auto_commit({
        vault_folder = vault_folder,
        auto_save_interval = 10 * 60,
        commit_interval = 60 * 60,
      })
    end,
  },
}
