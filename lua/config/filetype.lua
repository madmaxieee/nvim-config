vim.filetype.add({
  extension = {
    -- keep-sorted start
    d2 = "d2",
    justfile = "just",
    log = "log",
    mdx = "mdx",
    typ = "typst",
    -- keep-sorted end
  },
  pattern = {
    -- keep-sorted start
    [".*/%.env.*"] = "conf",
    [".*/ghostty/config"] = "conf",
    [".*/kitty/%w+%.conf"] = "kitty",
    [".*/logcat%.?%d*"] = "log",
    [".*/logcat.*%.txt"] = "log",
    -- keep-sorted end
  },
})
