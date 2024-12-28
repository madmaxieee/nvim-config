vim.filetype.add {
  extension = {
    typ = "typst",
    mdx = "mdx",
    d2 = "d2",
    log = "log",
    justfile = "just",
  },
  pattern = {
    ["\\.env.*"] = "sh",
    [".*/ghostty/config"] = "toml",
  },
}
