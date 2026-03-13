local kv = require("kv")

vim.api.nvim_create_user_command("KvReload", kv.reload, {
  desc = "Load kv settings",
  nargs = 0,
})

vim.api.nvim_create_user_command("KvSet", function(opts)
  if #opts.fargs ~= 2 then
    vim.notify("Usage: KvSet <key> <value>", vim.log.levels.ERROR)
    return
  end
  local key, value = opts.fargs[1], opts.fargs[2]
  if not vim.tbl_contains(kv.keys, key) then
    vim.notify("kv: invalid key: " .. key, vim.log.levels.ERROR)
    return
  end
  kv.set(key, value)
  kv.save()
  vim.notify("kv: set " .. key .. " = " .. value, vim.log.levels.INFO)
end, {
  nargs = "+",
  complete = function(_, cmd_line, _)
    local parts = vim.split(cmd_line, "%s+")
    if #parts == 2 then
      return kv.keys
    elseif #parts == 3 then
      local key = parts[2]
      if key == "theme" then
        return { "dark", "light" }
      elseif key == "colorscheme" then
        return vim.fn.getcompletion("", "color")
      elseif key == "colorscheme_light" then
        return vim.fn.getcompletion("", "color")
      end
    end
  end,
  desc = "Set a kv key",
})

vim.api.nvim_create_user_command("KvGet", function(opts)
  if #opts.fargs == 0 then
    local msg = "kv settings:"
    for _, k in ipairs(kv.keys) do
      msg = msg .. string.format("\n  %s = %s", k, tostring(kv.get(k)))
    end
    vim.notify(msg, vim.log.levels.INFO)
    return
  end
  local key = opts.fargs[1]
  if not vim.tbl_contains(kv.keys, key) then
    vim.notify("kv: invalid key: " .. key, vim.log.levels.ERROR)
    return
  end
  local value = kv.get(key)
  vim.notify("kv: " .. key .. " = " .. tostring(value), vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = function()
    return kv.keys
  end,
  desc = "Get a kv key value",
})

local augroup = vim.api.nvim_create_augroup("kv", { clear = true })

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = augroup,
  callback = kv.reload,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = augroup,
  callback = kv.save,
})
