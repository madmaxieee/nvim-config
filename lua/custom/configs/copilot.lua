local opts = {
  panel = {
    enabled = true,
    auto_refresh = true,
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
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    svn = false,
    cvs = false,
    ["*"] = true,
  },
}
return opts
