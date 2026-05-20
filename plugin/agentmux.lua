local agentmux = require("agentmux")

local map = require("utils").safe_keymap_set

map({ "n", "x" }, "<C-.>", function()
  if not agentmux.is_active() then
    agentmux.start()
  end
  agentmux.focus()
end, {})

map({ "n", "x" }, "<leader>at", function()
  agentmux.send("@this: ", { submit = false })
  agentmux.focus()
end, {})

local kv = require("kv")
if kv.get("agentmux_restore") then
  kv.set("agentmux_restore", false)
  kv.save()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      vim.schedule(agentmux.start)
    end,
  })
end

vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("agentmux.cleanup", { clear = true }),
  desc = "cleanup agent pane on exit",
  callback = function()
    agentmux.stop()
  end,
})
