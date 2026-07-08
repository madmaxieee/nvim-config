local M = {}

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    local group_id =
      vim.api.nvim_create_augroup(("LazyLoad:%s"):format(name), {})
    vim.api.nvim_create_autocmd("User", {
      group = group_id,
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          vim.api.nvim_del_augroup_by_id(group_id)
          fn(name)
          return true
        end
      end,
    })
  end
end

---@param name string
function M.is_loaded(name)
  local lazy_config = require("lazy.core.config")
  if lazy_config.plugins[name] and lazy_config.plugins[name]._.loaded then
    return true
  else
    return false
  end
end

return M
