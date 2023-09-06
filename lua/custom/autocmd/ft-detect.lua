-- configure filetype detection
local filetypeGroup = vim.api.nvim_create_augroup("Filetype", { clear = true })

local fileDetectionMap = {
  ["*.tpp"] = "cpp",
  ["*.typ"] = "typst",
}

local set_filetype = function(pattern, ft)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = filetypeGroup,
    pattern = pattern,
    callback = function()
      vim.bo.filetype = ft
    end,
  })
end

for pattern, ft in pairs(fileDetectionMap) do
  set_filetype(pattern, ft)
end
