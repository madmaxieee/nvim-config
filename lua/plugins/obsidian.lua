local vault_folder = vim.fn.resolve(vim.fn.expand "~/obsidian")

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

local auto_save_interval = 600 * 1000 -- milliseconds
local commit_interval = 60 * 60 -- seconds

---@diagnostic disable-next-line: undefined-field
local auto_save_timer = vim.uv.new_timer()

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
    git "push"
  end
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  event = {
    "BufReadPre " .. vault_folder .. "/**.md",
    "BufNewFile " .. vault_folder .. "/**.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("obsidian").setup {
      workspaces = {
        {
          name = "notes",
          path = "~/obsidian/notes",
        },
      },
    }

    vim.wo.conceallevel = 1

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

    vim.cmd.cabbrev("O", "Obsidian")
    local map = require("utils").safe_keymap_set
    map("n", "<leader>fo", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian search" })
  end,
}
