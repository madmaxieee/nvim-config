local agentmux = require("agentmux")

local map = require("utils").safe_keymap_set

map({ "n", "x" }, "<C-.>", function()
  if not agentmux.is_active() then
    agentmux.start()
  end
  agentmux.focus()
end, { desc = "Toggle agent focus" })

map({ "n", "x" }, "<leader>aa", function()
  agentmux.ask("", { submit = true })
end, { desc = "Ask agent" })

map({ "n", "x" }, "<leader>at", function()
  agentmux.send("@this: ", { submit = false })
  agentmux.focus()
end, { desc = "Send context to agent and focus agent" })

map({ "n", "x" }, "<leader>af", function()
  agentmux.pick_prompts()
end, { desc = "Pick a predefined prompt" })

local kv = require("kv")
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local provider = kv.get("agentmux_provider")
    if type(provider) == "string" then
      agentmux.set_provider(provider)
    end
  end,
})

local function set_provider(provider)
  if not agentmux.set_provider(provider) then
    return false
  end
  kv.set("agentmux_provider", provider)
  kv.save()
  return true
end

local agentmux_restore = kv.get("agentmux_restore")
if agentmux_restore then
  kv.set("agentmux_restore", nil)
  kv.save()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      vim.schedule(function()
        require("agentmux").restore(agentmux_restore)
      end)
    end,
  })
end

-- does not trigger on :restart
vim.api.nvim_create_autocmd("UILeave", {
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
        if set_provider(choice) then
          vim.notify(
            "AgentMux provider set to: " .. choice,
            vim.log.levels.INFO
          )
        end
      end
    end)
    return
  end

  if set_provider(provider) then
    vim.notify("AgentMux provider set to: " .. provider, vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  complete = function()
    return agentmux.get_providers()
  end,
  desc = "Get or set the AgentMux provider",
})
