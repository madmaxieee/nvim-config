local M = {}

M.create_obsidian_command = function()
  local command_map = {
    backlinks = "ObsidianBacklinks",
    dailies = "ObsidianDailies",
    extract = "ObsidianExtractNote",
    follow = "ObsidianFollowLink",
    link = "ObsidianLink",
    links = "ObsidianLinks",
    linknew = "ObsidianLinkNew",
    new = "ObsidianNew",
    newfromtemplate = "ObsidianNewFromTemplate",
    open = "ObsidianOpen",
    pasteimg = "ObsidianPasteImg",
    rename = "ObsidianRename",
    search = "ObsidianSearch",
    switch = "ObsidianQuickSwitch",
    tags = "ObsidianTags",
    template = "ObsidianTemplate",
    toc = "ObsidianTOC",
    today = "ObsidianToday",
    tomorrow = "ObsidianTomorrow",
    check = "ObsidianToggleCheckbox",
    workspace = "ObsidianWorkspace",
    yesterday = "ObsidianYesterday",
  }
  vim.api.nvim_create_user_command("Obsidian", function(opts)
    local command = command_map[opts.fargs[1]]
    local real_args = table.concat(opts.fargs, " ", 2)
    if command then
      vim.cmd(command .. " " .. real_args)
    else
      vim.notify("Invalid Obsidian command: " .. opts.fargs[1], vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    complete = function(_, line)
      local l = vim.split(line, "%s+")
      local options_list = vim.tbl_keys(command_map)
      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[#l])
      end, options_list)
    end,
  })
  vim.cmd.cabbrev("O", "Obsidian")
end

-- register cmp sources for blink.compat
M.register_sources = function()
  local cmp = require "cmp"
  cmp.register_source("obsidian", require("cmp_obsidian").new())
  cmp.register_source("obsidian_new", require("cmp_obsidian_new").new())
  cmp.register_source("obsidian_tags", require("cmp_obsidian_tags").new())
end

local auto_save_timer = vim.uv.new_timer()
assert(auto_save_timer, "Failed to create timer")

---@class AutoCommitOptions
---@field vault_folder string
---@field auto_save_interval number
---@field commit_interval number
---@param opts AutoCommitOptions
M.auto_commit = function(opts)
  local auto_save_interval = opts.auto_save_interval * 1000
  local commit_interval = opts.commit_interval
  local vault_folder = opts.vault_folder

  local function git(args)
    local command = ("git -C '" .. vault_folder .. "' " .. args)
    local handle = io.popen(command)
    if handle then
      local result = handle:read "*a"
      handle:close()
      return result
    end
  end

  local function auto_commit(interval)
    local commit_time_str = git "log -1 --format=%ct"
    local commit_time = tonumber(commit_time_str)
    if commit_time == nil then
      return
    end
    local current_time = os.time()
    if current_time - commit_time >= interval then
      vim.cmd "wa"
      git "add --all"
      git "commit -m 'auto commit'"
      git "push --quiet"
    end
  end

  if git "rev-parse --is-inside-work-tree" == "true\n" then
    local auto_save_group = vim.api.nvim_create_augroup("SaveObsidian", { clear = true })
    vim.api.nvim_create_autocmd({ "FocusGained" }, {
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
    vim.api.nvim_create_autocmd({ "FocusLost" }, {
      group = auto_save_group,
      callback = function()
        if vim.fn.getcwd() ~= vault_folder then
          return
        end
        if not auto_save_timer:is_active() then
          auto_save_timer:start(auto_save_interval, 0, function()
            -- can't call vim api's like vim.cmd directly in uv callbacks
            vim.schedule(function()
              auto_commit(commit_interval)
            end)
          end)
        end
      end,
    })
    vim.api.nvim_create_autocmd({ "VimLeave" }, {
      group = auto_save_group,
      callback = function()
        if vim.fn.getcwd() ~= vault_folder then
          return
        end
        auto_commit(commit_interval)
      end,
    })
  end
end

return M
