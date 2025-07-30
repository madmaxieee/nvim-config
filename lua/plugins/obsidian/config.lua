local M = {}

local auto_save_timer = assert(vim.uv.new_timer(), "Failed to create timer")

---@class AutoCommitOptions
---@field vault_folder string
---@field auto_save_interval number: check if we need to commit after inactive for [auto_save_interval] seconds
---@field commit_interval number: only commit new changes if last commit is older than [commit_interval] seconds ago
---@param opts AutoCommitOptions
function M.setup_auto_commit(opts)
  local auto_save_interval = opts.auto_save_interval * 1000
  local commit_interval = opts.commit_interval
  local vault_folder = vim.fn.fnameescape(opts.vault_folder)

  local function git(args)
    local command = "git -C '" .. vault_folder .. "' " .. args
    local handle = io.popen(command)
    if handle then
      local result = handle:read "*a"
      handle:close()
      return result
    end
  end

  ---@param message string?: the commit message
  ---@param write_all boolean?: the commit message
  local function try_commit(message, write_all)
    local commit_time_str = git "log -1 --format=%ct"
    local commit_time = tonumber(commit_time_str)
    if commit_time == nil then
      return
    end
    local commit_message = message and vim.fn.escape(message, [['\]]) or "auto commit"
    local current_time = os.time()
    if current_time - commit_time >= commit_interval then
      if write_all then
        vim.cmd "wa"
      end
      git "add --all"
      git("commit  -m '" .. commit_message .. "'")
      git "push --quiet"
    end
  end

  if git "rev-parse --is-inside-work-tree" == "true\n" then
    local auto_save_group = vim.api.nvim_create_augroup("SaveObsidian", { clear = true })
    vim.api.nvim_create_autocmd("FocusGained", {
      group = auto_save_group,
      callback = function()
        if vim.fn.getcwd() ~= vault_folder then
          return
        end
        if auto_save_timer:is_active() then
          auto_save_timer:stop()
        end
      end,
    })
    vim.api.nvim_create_autocmd("FocusLost", {
      group = auto_save_group,
      callback = function()
        if vim.fn.getcwd() ~= vault_folder then
          return
        end
        if not auto_save_timer:is_active() then
          auto_save_timer:start(auto_save_interval, 0, function()
            -- can't call vim api's like vim.cmd in uv callback
            vim.schedule(function()
              try_commit("auto commit: inactive", true)
            end)
          end)
        end
      end,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = auto_save_group,
      callback = function()
        if vim.fn.getcwd() ~= vault_folder then
          return
        end
        -- can't call vim.cmd here, not sure why
        try_commit "auto commit: leave"
      end,
    })
  end
end

return M
