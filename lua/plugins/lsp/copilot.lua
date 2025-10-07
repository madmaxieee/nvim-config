local lsp_utils = require "plugins.lsp.utils"

local function should_ask()
  return vim.fn.expand "$USER" == "maxcchuang"
end

local function confirm_use_copilot()
  local choice = vim.fn.confirm("enable copilot?", "&yes\n&no", 2)
  if choice == 1 then
    return true
  else
    return false
  end
end

vim.api.nvim_create_autocmd("SessionLoadPost", {
  once = true,
  callback = function()
    if lsp_utils.get_lsp_enabled "copilot" and should_ask() then
      vim.defer_fn(function()
        local enable = confirm_use_copilot()
        if enable then
          vim.cmd "CopilotEnable"
        else
          vim.cmd "CopilotDisable"
        end
      end, 300)
    end
  end,
})

vim.api.nvim_create_user_command("CopilotEnable", "LspEnable copilot", {})
vim.api.nvim_create_user_command("CopilotDisable", "LspDisable copilot", {})
