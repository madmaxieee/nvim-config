return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    init = function()
      vim.cmd.cabbrev("T", "Telescope")
    end,

    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
            },
          },
          mappings = {
            i = {
              ["<c-t>"] = function(prompt_bufnr)
                local trouble = require("trouble.providers.telescope")
                trouble.open_with_trouble(prompt_bufnr)
              end,
              ["<c-f>"] = actions.to_fuzzy_refine,
            },
            n = {
              ["<c-t>"] = function(prompt_bufnr)
                local trouble = require("trouble.providers.telescope")
                trouble.open_with_trouble(prompt_bufnr)
              end,
              ["<c-f>"] = actions.to_fuzzy_refine,
            },
          },
        },
        pickers = {
          buffers = {
            mappings = {
              n = {
                ["x"] = actions.delete_buffer,
              },
            },
          },
        },
      })
    end,
  },
}
