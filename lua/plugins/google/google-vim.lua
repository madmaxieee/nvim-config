if vim.fn.isdirectory("/usr/share/vim/google") ~= 1 then
  return {}
end

return {
  {
    "google-filetypes",
    dir = "/usr/share/vim/google/google-filetypes",
    lazy = false,
    dependencies = {
      {
        dir = "/usr/share/vim/google/maktaba",
      },
      {
        dir = "/usr/share/vim/google/googlelib",
      },
    },
  },
}
