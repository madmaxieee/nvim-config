return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  init = function()
    vim.opt.cmdheight = 0
    vim.cmd.cabbrev("N", "Noice")
  end,
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = false, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    views = {
      confirm = {
        backend = "popup",
        relative = "editor",
        align = "center",
        position = {
          row = "40%",
          col = "50%",
        },
        size = "auto",
        border = {
          style = "rounded",
          padding = { 0, 2 },
        },
      },
    },
  },
}
