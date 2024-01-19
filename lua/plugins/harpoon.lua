local map = require("utils").safe_keymap_set

local function toggle_telescope(harpoon_files)
  local conf = require("telescope.config").values
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table {
        results = file_paths,
      },
      previewer = conf.file_previewer {},
      sorter = conf.generic_sorter {},
    })
    :find()
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    {
      "<leader>h",
      mode = "n",
      function()
        local harpoon = require "harpoon"
        harpoon.ui:toggle_quick_menu(harpoon:list(), {
          ui_fallback_width = 30,
          ui_width_ratio = 0.4,
        })
      end,
      desc = "Toggle harpoon ui",
    },
    {
      "<leader>j",
      mode = "n",
      function()
        toggle_telescope(require("harpoon"):list())
      end,
      desc = "Open harpoon list in telescope",
    },
    {
      "<leader>a",
      mode = "n",
      function()
        require("harpoon"):list():append()
      end,
      desc = "Append to Harpoon",
    },
    {
      "<Tab>",
      mode = "n",
      function()
        require("harpoon"):list():next { ui_nav_wrap = true }
      end,
      desc = "Next Harpoon",
    },
    {
      "<S-Tab>",
      mode = "n",
      function()
        require("harpoon"):list():prev { ui_nav_wrap = true }
      end,
      desc = "Previous Harpoon",
    },
  },
  init = function()
    for i = 1, 9 do
      map("n", "<leader>" .. i, function()
        require("harpoon"):list():select(i)
      end, { desc = "Go to file " .. i })
    end
  end,
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup {}
  end,
}
