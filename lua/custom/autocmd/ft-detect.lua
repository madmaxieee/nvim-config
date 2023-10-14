-- configure filetype detection
local ft_group = vim.api.nvim_create_augroup("Filetype", { clear = true })

local ft_detect_map = {
  [".env*"] = "sh",
}

local set_filetype = function(pattern, ft)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = ft_group,
    pattern = pattern,
    callback = function()
      vim.bo.filetype = ft
    end,
  })
end

for pattern, ft in pairs(ft_detect_map) do
  set_filetype(pattern, ft)
end
