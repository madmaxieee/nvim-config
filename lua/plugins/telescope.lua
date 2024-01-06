return {
  "nvim-telescope/telescope.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  keys = {
    {
      "<leader>fg",
      mode = "n",
      "<cmd> Telescope git_files <CR>",
      desc = "Find git files",
    },
    {
      "<leader>fd",
      mode = "n",
      "<cmd> Telescope diagnostics <CR>",
      desc = "Find diagnostic",
    },
    {
      "<leader>fs",
      mode = "n",
      "<cmd> Telescope lsp_document_symbols <CR>",
      desc = "Search document symbols",
    },
    {
      "<leader>ws",
      mode = "n",
      "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>",
      desc = "Search workspace symbols",
    },
    {
      "<leader>ma",
      mode = "n",
      "<cmd> Telescope marks <CR>",
      desc = "Search marks",
    },
    {
      "<leader>fj",
      mode = "n",
      "<cmd> Telescope jumplist <CR>",
      desc = "Search jumplist",
    },
    {
      "<leader>gs",
      mode = "n",
      "<cmd> Telescope git_status <CR>",
      desc = "Git status",
    },
    {
      "<leader>y",
      mode = "n",
      "<cmd> Telescope neoclip <CR>",
      desc = "Search clipboard history",
    },
    {
      "<leader>ff",
      mode = "n",
      "<cmd> Telescope find_files <CR>",
      desc = "Find files",
    },
    {
      "<leader>fa",
      mode = "n",
      "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
      desc = "Find all",
    },
    {
      "<leader>fw",
      mode = "n",
      "<cmd> Telescope live_grep <CR>",
      desc = "Live grep",
    },
    {
      "<leader>fb",
      mode = "n",
      "<cmd> Telescope buffers <CR>",
      desc = "Find buffers",
    },
    {
      "<leader>fh",
      mode = "n",
      "<cmd> Telescope help_tags <CR>",
      desc = "Help page",
    },
    {
      "<leader>fz",
      mode = "n",
      "<cmd> Telescope current_buffer_fuzzy_find <CR>",
      desc = "Find in current buffer",
    },
    {
      "<leader>tr",
      mode = "n",
      "<cmd> Telescope resume <CR>",
      desc = "Telescope resume",
    },
    {
      "<leader>cm",
      mode = "n",
      "<cmd> Telescope git_commits <CR>",
      desc = "Git commits",
    },
    {
      "<leader>ma",
      mode = "n",
      "<cmd> Telescope marks <CR>",
      desc = "telescope bookmarks",
    },
    {
      "<leader>fw",
      mode = "v",
      function()
        require("telescope.builtin").grep_string { path_display = { "shorten" } }
      end,
      desc = "Grep string",
    },
  },
  cmd = "Telescope",
  config = function()
    require("telescope").setup {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "node_modules", "^.git/" },
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          n = { ["q"] = require("telescope.actions").close },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    }
  end,
}
