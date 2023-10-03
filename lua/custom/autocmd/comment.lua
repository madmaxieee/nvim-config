-- configure commentstring
local commentstring_group = vim.api.nvim_create_augroup("Commentstring", { clear = true })

local commentstring_pattern_map = {
  ["*.dof"] = "// %s",
}

local set_commentstring = function(pattern, commentstring)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = commentstring_group,
    pattern = pattern,
    callback = function()
      vim.bo.commentstring = commentstring
    end,
  })
end

for pattern, string in pairs(commentstring_pattern_map) do
  set_commentstring(pattern, string)
end

local commentstring_filetype_map = {
  kdl = "// %s",
  kitty = "# %s",
}

local set_commentstring_filetype = function(filetype, commentstring)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = commentstring_group,
    pattern = filetype,
    callback = function()
      vim.bo.commentstring = commentstring
    end,
  })
end

for filetype, string in pairs(commentstring_filetype_map) do
  set_commentstring_filetype(filetype, string)
end
