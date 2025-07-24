local function is_difftool_mode()
  for _, arg in ipairs(vim.v.argv) do
    if arg:match [[^%+DiffviewOpen]] then
      return true
    end
  end
  return false
end

vim.g.difftool_mode = is_difftool_mode()
