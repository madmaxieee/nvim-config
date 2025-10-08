local repeatable = require "repeatable"
local utils = require "utils"

local next_ref_repeat, prev_ref_repeat = repeatable.make_repeatable_move_pair( --
  function()
    utils.set_jumplist()
    require("snacks").words.jump(vim.v.count1, true)
  end,
  function()
    utils.set_jumplist()
    require("snacks").words.jump(-vim.v.count1, true)
  end
)

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "<leader>x",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>.",
        function()
          require("snacks").scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          require("snacks").scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader>z",
        function()
          require("snacks").zen()
        end,
        desc = "Toggle zen mode",
      },
      {
        "<leader>e",
        function()
          require("snacks").explorer()
        end,
        desc = "Toggle explorer",
      },
      {
        "]]",
        next_ref_repeat,
        desc = "Next Reference",
      },
      {
        "[[",
        prev_ref_repeat,
        desc = "Prev Reference",
      },
      {
        "<A-g>",
        mode = { "n", "t" },
        function()
          require("snacks").lazygit.open()
        end,
        desc = "Toggle lazygit",
      },
      {
        "<leader>lg",
        function()
          require("snacks").lazygit.log()
        end,
        desc = "Open lazygit log view",
      },
      {
        "<leader>lf",
        function()
          require("snacks").lazygit.log_file()
        end,
        desc = "Open lazygit log view for current file",
      },
      {
        "<A-e>",
        mode = { "n", "t" },
        function()
          require("snacks").terminal.toggle()
        end,
        desc = "Toggle terminal",
      },
    },

    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      image = {
        enabled = true,
        math = {
          typst = {
            -- change font size
            tpl = [[
        #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
        #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
        #set text(size: 18pt, fill: rgb("${color}"))
        ${header}
        ${content}]],
          },
        },
      },
      indent = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = false },
      picker = {
        enabled = true,
        ui_select = true,
      },
      quickfile = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        input = {
          relative = "cursor",
          row = 1,
        },
        zen = {
          relative = "editor",
          backdrop = { transparent = false },
        },
      },
    },

    init = function()
      vim.api.nvim_create_user_command("Zen", function()
        require("snacks").zen()
      end, {
        desc = "Toggle zen mode",
      })

      vim.api.nvim_create_user_command("Pick", function(opts)
        local source = opts.fargs[1]
        if source then
          if require("snacks").picker[source] then
            require("snacks").picker[source]()
          else
            vim.notify("unknown snacks picker source: " .. source, vim.log.levels.ERROR)
          end
        else
          require("snacks").picker()
        end
      end, {
        desc = "Open Snacks Picker",
        nargs = "?",
        complete = function()
          return vim.tbl_keys(require("snacks").picker.sources)
        end,
      })
      vim.cmd.cabbrev("P", "Pick")

      vim.api.nvim_set_hl(0, "SnacksImageMath", { link = "Normal" })

      _G.dd = function(...)
        require("snacks").debug.inspect(...)
      end
      _G.bt = function()
        require("snacks").debug.backtrace()
      end
    end,
  },

  require "plugins.snacks.snacks-picker",
}
