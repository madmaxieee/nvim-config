return {
  "nvim-mini/mini.diff",
  event = "VeryLazy",
  config = function()
    local gen_custom_source = require("plugins.mini-diff.gen-custom-source")

    require("mini.diff").setup({
      view = {
        style = "sign",
        signs = {
          add = "│",
          change = "│",
          delete = "󰍵",
        },
      },
      mappings = {
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
      options = {
        algorithm = "patience",
      },
      source = {
        require("mini.diff").gen_source.git(),
        gen_custom_source.hg(),
        gen_custom_source.jj(),
        require("mini.diff").gen_source.save(),
        require("mini.diff").gen_source.none(),
      },
    })

    local map_repeatable_pair = require("utils").map_repeatable_pair
    local map = require("utils").safe_keymap_set

    map_repeatable_pair({ "n" }, {
      next = {
        "]h",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            require("mini.diff").goto_hunk("next", { wrap = true })
          end
        end,
        { desc = "Next hunk" },
      },
      prev = {
        "[h",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            require("mini.diff").goto_hunk("prev", { wrap = true })
          end
        end,
        { desc = "Previous hunk" },
      },
    })

    local MINI_DIFF_TEXTOBJECT = "ih"

    map({ "o", "x" }, MINI_DIFF_TEXTOBJECT, function()
      require("mini.diff").textobject()
    end, { desc = "Current hunk text object" })

    map("n", "<leader>hr", function()
      return require("mini.diff").operator("reset") .. MINI_DIFF_TEXTOBJECT
    end, {
      expr = true,
      remap = true,
      desc = "Reset current hunk",
    })

    map({ "x" }, "<leader>hr", function()
      return require("mini.diff").operator("reset")
    end, {
      expr = true,
      desc = "Reset selected lines",
    })

    map("n", "<leader>gd", function()
      require("mini.diff").toggle_overlay(0)
    end, { desc = "Toggle diff overlay" })
  end,
}
