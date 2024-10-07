local function config_copilot()
  require("copilot").setup {
    panel = {
      enabled = false,
      auto_refresh = false,
      layout = {
        position = "bottom", -- | top | left | right
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<A-l>",
        accept_word = false,
        accept_line = false,
        next = "<A-]>",
        prev = "<A-[>",
        dismiss = "<C-]>",
      },
    },
    filetypes = {
      help = false,
      gitrebase = false,
      ["*"] = true,
    },
  }
  if vim.g.EnableCopilot == 1 then
    vim.cmd "Copilot enable"
  else
    vim.cmd "Copilot disable"
  end
end

vim.api.nvim_create_user_command("EnableCopilot", function()
  vim.g.EnableCopilot = 1
  config_copilot()
end, {})
vim.api.nvim_create_user_command("DisableCopilot", function()
  vim.g.EnableCopilot = 0
  if vim.fn.exists "Copilot" then
    vim.cmd "Copilot disable"
  end
end, {})

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  config = config_copilot,
}
