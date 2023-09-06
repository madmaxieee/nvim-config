-- configure commentstring
local commentstring_group = vim.api.nvim_create_augroup("Commentstring", { clear = true })

local commentstring_map = {
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

for pattern, string in pairs(commentstring_map) do
  set_commentstring(pattern, string)
end
