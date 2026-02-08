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
    -- stylua: ignore
    vim.system({
      -- create a new pain in detached mode (no focus)
      "tmux", "split-window", "-d",
      -- print the pane id to stdout so we can capture it
      "-P", "-F", "#{pane_id}",
      -- split horizontally and set the width to 35% of the screen
      "-h", "-p", "35",
      -- the opencode command
      "exec opencode --port",
    }, function(res)
      if res.code ~= 0 then
        return
      end
      provider.pane_id = vim.trim(res.stdout)
      vim.system({
        -- target the pane we just created
        "tmux", "set-option", "-t", provider.pane_id,
        -- disable allow-passthrough so the terminal does not send escape code
        -- to the vim pane
        "-p", "allow-passthrough", "off",
      })
    end)
  end
end

local function stop()
  local pane_id = get_pane_id()
  if pane_id then
    -- stylua: ignore
    vim.system({
      "tmux", "send-keys", "-t", pane_id,
      -- clear prompt then exit opencode
      "C-c", "/exit",
    })
    provider.pane_id = nil
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
        stop = stop,
        toggle = function(_) end,
      },
    }
  end,
  keys = {
    {
      "<C-.>",
      mode = "n",
      function()
        if provider.pane_id then
          vim.system({ "tmux", "resize-pane", "-Z" })
        else
          -- trigger opencode.nvim to start the provider
          require("opencode").prompt("", {})
        end
      end,
      desc = "Toggle opencode",
    },
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
