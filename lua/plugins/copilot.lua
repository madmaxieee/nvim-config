return {
  "zbirenbaum/copilot.lua",
  -- event = "InsertEnter",
  cmd = "Copilot",
  opts = {
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
  },
}
