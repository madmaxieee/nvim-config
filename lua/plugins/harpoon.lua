local map = require("utils").safe_keymap_set

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  init = function()
    map("n", "<leader>a", function()
      require("harpoon"):list():append()
    end, { desc = "Append to Harpoon" })
    map("n", "<leader>j", function()
      local harpoon = require "harpoon"
      harpoon.ui:toggle_quick_menu(harpoon:list(), {
        ui_fallback_width = 30,
        ui_width_ratio = 0.4,
      })
    end, { desc = "Toggle harpoon ui" })

    for i = 1, 9 do
      map("n", "<leader>" .. i, function()
        require("harpoon"):list():select(i)
      end, { desc = "Go to file " .. i })
    end

    map("n", "<Tab>", function()
      require("harpoon"):list():next { ui_nav_wrap = true }
    end, { desc = "Next file" })
    map("n", "<S-Tab>", function()
      require("harpoon"):list():prev { ui_nav_wrap = true }
    end, { desc = "Previous file" })
  end,
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup {}
  end,
}
