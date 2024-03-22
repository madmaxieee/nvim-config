return {
  cond = not vim.g.minimal_mode,
  "utilyre/barbecue.nvim",
  lazy = false,
  dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
  init = function()
    -- to avoid layout shift when the winbar is loaded
    vim.opt.winbar = " "
  end,
  config = function()
    require("barbecue").setup {
      show_modified = true,
      create_autocmd = false, -- prevent barbecue from updating itself automatically
    }

    vim.api.nvim_create_autocmd({
      "WinScrolled",
      "WinResized",
      "BufWinEnter",
      "CursorHold",
      "InsertLeave",
      "BufModifiedSet",
    }, {
      group = vim.api.nvim_create_augroup("barbecue.updater", {}),
      callback = function()
        require("barbecue.ui").update()
      end,
    })
  end,
}
