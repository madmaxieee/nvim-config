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

local function snacks_debug()
  _G.dd = function(...)
    require("snacks").debug.inspect(...)
  end
  _G.bt = function()
    require("snacks").debug.backtrace()
  end
  vim.print = _G.dd
end

local function create_picker_command()
  local subcommands = vim.tbl_keys(require("snacks").picker.sources)
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
    nargs = "?",
    complete = function(_, line)
      local l = vim.split(line, "%s+")
      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[#l])
      end, subcommands)
    end,
  })
  vim.cmd.cabbrev("P", "Pick")
end

return {
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
      "]]",
      next_ref_repeat,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      prev_ref_repeat,
      desc = "Prev Reference",
      mode = { "n", "t" },
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
  },

  init = function()
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("SnacksDebug", { clear = true }),
      desc = "Setup snacks debug",
      pattern = (vim.fn.expand "~/.local/share/nvim/lazy/") .. "*",
      once = true,
      callback = snacks_debug,
    })
  end,

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
  config = function(_, opts)
    require("snacks").setup(opts)

    vim.api.nvim_create_user_command("SnacksDebug", snacks_debug, {})
    vim.api.nvim_create_user_command("Zen", function()
      require("snacks").zen()
    end, {})

    local map = require("utils").safe_keymap_set
    map( --
      { "n" },
      "<leader>z",
      function()
        require("snacks").zen()
      end,
      { desc = "Toggle Zen Mode" }
    )

    create_picker_command()
    require("plugins.fuzzy-finder.snacks-picker.keymaps").set_keymaps()

    vim.api.nvim_set_hl(0, "SnacksImageMath", { link = "Normal" })
  end,
}
