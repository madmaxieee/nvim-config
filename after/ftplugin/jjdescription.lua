if require("flags").in_google3 then
  local g3_jj_desc_group =
    vim.api.nvim_create_augroup("jjdescription_google3", { clear = false })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = g3_jj_desc_group,
    buffer = 0,
    callback = function()
      local line = vim.api.nvim_get_current_line()
      local tag, rest = line:match("^([A-Z]+)=(.*)$")
      if not tag or (tag ~= "BUG" and tag ~= "FIXED") then
        return
      end

      local cleaned_rest = (rest:gsub("[#?].*", ""))
      local d8 = "%d%d%d%d%d%d%d%d+"
      local bug_id = cleaned_rest:match("/issues/(" .. d8 .. ")")
        or cleaned_rest:match("b/(" .. d8 .. ")")
        or cleaned_rest:match("/(" .. d8 .. ")")
        or cleaned_rest:match("(" .. d8 .. ")")

      if not bug_id then
        return
      end

      local new_line = tag .. "=" .. bug_id
      if line ~= new_line then
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_set_current_line(new_line)
        vim.api.nvim_win_set_cursor(
          0,
          { cursor[1], math.min(cursor[2], #new_line) }
        )
      end
    end,
  })
end
