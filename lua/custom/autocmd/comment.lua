-- configure commentstring
local commentstringGroup = vim.api.nvim_create_augroup("Commentstring", { clear = true })

local commentstringMap = {
  ["*.dof"] = "// %s",
}

local set_commentstring = function(pattern, commentstring)
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = commentstringGroup,
    pattern = pattern,
    callback = function()
      vim.bo.commentstring = commentstring
    end,
  })
end

for pattern, commentstring in pairs(commentstringMap) do
  set_commentstring(pattern, commentstring)
end
