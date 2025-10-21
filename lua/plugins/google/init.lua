if vim.fn.isdirectory "/google/bin" ~= 1 then
  return {}
end

return {
  {
    import = "plugins.google",
  },
}
