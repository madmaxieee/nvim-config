local agentmux = require("agentmux")

local map = require("utils").safe_keymap_set

map({ "n", "x" }, "<C-.>", function()
  if not agentmux.is_active() then
    agentmux.start()
  end
  agentmux.focus()
end, {})

map({ "n", "x" }, "<leader>aa", function()
  agentmux.ask("", { submit = true })
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

vim.api.nvim_create_user_command("AgentMuxProvider", function(opts)
  local provider = opts.fargs[1]
  if not provider or provider == "" then
    local providers = agentmux.get_providers()
    local current = agentmux.get_provider()
    vim.ui.select(providers, {
      prompt = "Select AgentMux Provider (current: " .. current .. ")",
    }, function(choice)
      if choice then
        if agentmux.set_provider(choice) then
          vim.notify(
            "AgentMux provider set to: " .. choice,
            vim.log.levels.INFO
          )
        end
      end
    end)
    return
  end

  if agentmux.set_provider(provider) then
    vim.notify("AgentMux provider set to: " .. provider, vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  complete = function()
    return agentmux.get_providers()
  end,
  desc = "Get or set the AgentMux provider",
})
