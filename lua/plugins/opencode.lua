---@type {pane_id:string?}
local provider = {}

local function get_pane_id()
  if provider.pane_id then
    local res = vim
      .system({
        "tmux",
        "list-panes",
        "-t",
        provider.pane_id,
      })
      :wait()
    if res.code ~= 0 then
      provider.pane_id = nil
    end
  end
  return provider.pane_id
end

local function start(_)
  local pane_id = get_pane_id()
  if not pane_id then
    vim.system({
      "tmux",
      "split-window",
      "-d",
      "-P",
      "-F",
      "#{pane_id}",
      "-h",
      "-p",
      "35",
      "exec opencode --port",
    }, function(res)
      if res.code ~= 0 then
        return
      end
      provider.pane_id = vim.trim(res.stdout)
    end)
  end
end

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    ---@module 'snacks'
    ---@diagnostic disable-next-line: missing-fields
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  init = function()
    ---@module 'opencode'
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = {
        start = start,
        stop = function(_) end,
        toggle = function(_) end,
      },
    }
  end,
  keys = {
    {
      "<leader>ac",
      mode = "n",
      function()
        require("opencode").prompt("", { clear = true })
      end,
      desc = "Clear opencode prompt",
    },
    {
      "<C-s>",
      mode = "n",
      function()
        require("opencode").prompt("", { submit = true })
      end,
      desc = "Submit opencode prompt",
    },
    {
      "<leader>aa",
      mode = { "n", "x" },
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      desc = "Ask opencode…",
    },
    {
      "<leader>af",
      mode = { "n", "x" },
      function()
        require("opencode").select()
      end,
      desc = "Execute opencode action…",
    },
    {
      "go",
      mode = { "n", "x" },
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Add range to opencode",
      expr = true,
    },
    {
      "goo",
      mode = "n",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Add line to opencode",
      expr = true,
    },
    {
      "<S-C-u>",
      mode = "n",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll opencode up",
    },
    {
      "<S-C-d>",
      mode = "n",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll opencode down",
    },
  },
}
