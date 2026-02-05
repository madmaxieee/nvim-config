vim.filetype.add({
  extension = {
    typ = "typst",
    mdx = "mdx",
    d2 = "d2",
    log = "log",
    justfile = "just",
  },
  pattern = {
    [".*/%.env.*"] = "conf",
    [".*/ghostty/config"] = "conf",
    [".*/logcat%.?%d*"] = "log",
    [".*/kitty/%w+%.conf"] = "kitty",
  },
})
