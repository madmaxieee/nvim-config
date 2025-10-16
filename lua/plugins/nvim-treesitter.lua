local languages = {
  "nix",

  -- general purpose languages
  "c",
  "cpp",
  "doxygen",
  "rust",
  "go",
  "gomod",
  "gosum",
  "java",
  "zig",
  "python",

  -- scripting languages
  "bash",
  "fish",

  -- lua
  "lua",
  "luadoc",
  "luap",

  -- web
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "graphql",

  -- document
  "markdown",
  "markdown_inline",
  "typst",

  -- data
  "json",
  "jsonc",
  "kdl",
  "toml",
  "yaml",

  -- build system
  "just",
  "make",
  "cmake",
  "gn",
  "kconfig",
  "bp",
  "dockerfile",

  -- git
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",

  -- vim
  "vim",
  "vimdoc",

  -- misc
  "regex",
  "kitty",
  "ssh_config",

  -- custom
  "d2",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    init = function()
      local group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true })

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        group = group,
        callback = function()
          local parsers = require "nvim-treesitter.parsers"

          parsers.d2 = {
            tier = 0,
            ---@diagnostic disable-next-line: missing-fields
            install_info = {
              url = "https://github.com/ravsii/tree-sitter-d2",
              files = { "src/parser.c" },
              queries = "queries",
            },
          }
        end,
      })

      local syntax_on = {}
      local lsp_semantic_token_on = {}
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          local bufnr = args.buf
          local filetype = args.match

          local language = vim.treesitter.language.get_lang(filetype) or filetype
          if not vim.treesitter.language.add(language) then
            return
          end

          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          vim.treesitter.start(bufnr, language)

          local ft = vim.bo[bufnr].filetype
          if syntax_on[ft] then
            vim.bo[bufnr].syntax = "on"
          end

          if not lsp_semantic_token_on[ft] then
            vim.lsp.semantic_tokens.enable(false, { bufnr = bufnr })
          end
        end,
      })

      vim.treesitter.language.register("markdown", "mdx")

      require("nvim-treesitter").install(languages)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufRead", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
      max_lines = 10,
      min_window_height = 30,
      line_numbers = true,
      multiline_threshold = 5,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      zindex = 20,
      on_attach = nil,
    },
  },

  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  {
    "Wansmer/treesj",
    keys = {
      {
        "<leader>s",
        mode = { "n" },
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle treesj split join",
      },
    },
    opts = {
      use_default_keymaps = false,
    },
  },

  {
    "mtrajano/tssorter.nvim",
    cmd = "TSSort",
    ---@module "tssorter"
    ---@type TssorterOpts
    opts = {},
  },
}
