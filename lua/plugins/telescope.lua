return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    -- "nvim-treesitter/nvim-treesitter",
    "madmaxieee/nvim-treesitter", -- use my own fork for typst support
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
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
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
          },
        },
        file_ignore_patterns = {
          "node_modules/",
          "%.git/",
          "%.obsidian%-?.*/",
          "lazy%-lock%.json$",
          "pnpm%-lock%.yaml$",
          "package%-lock%.json$",
          "yarn%.lock$",
        },
        mappings = {
          n = { ["q"] = require("telescope.actions").close },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    }

    require("telescope").load_extension "fzf"
  end,
}
