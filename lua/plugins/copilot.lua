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

return {
  cond = vim.fn.expand "$USER" ~= "maxcchuang",
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "SessionLoadPost",
  init = function()
    vim.api.nvim_create_user_command("CopilotEnable", function()
      vim.g.EnableCopilot = 1
      config_copilot()
      vim.notify("enabled copilot", vim.log.levels.INFO)
    end, {})
    vim.api.nvim_create_user_command("CopilotDisable", function()
      vim.g.EnableCopilot = nil
      if vim.fn.exists ":Copilot" > 0 then
        vim.cmd "Copilot disable"
      end
      vim.notify("disabled copilot", vim.log.levels.INFO)
    end, {})
  end,
  config = config_copilot,
}
