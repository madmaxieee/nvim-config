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

    local function git(args)
      return vim.fn.system("git -C " .. vault_folder .. " " .. args)
    end

    vim.api.nvim_create_autocmd({ "FocusLost", "VimLeave" }, {
      group = vim.api.nvim_create_augroup("SaveObsidian", { clear = true }),
      callback = function()
        if vim.fn.getcwd() ~= vault_folder then
          return
        end
        local commit_time_str = git "log -1 --format=%ct"
        local commit_time = tonumber(commit_time_str)
        if commit_time == nil then
          vim.notify("could not retrieve commit time.", vim.log.levels.warn)
        end
        local current_time = os.time()
        if current_time - commit_time >= 3600 then
          vim.cmd "wa"
          git "add --all"
          git "commit -m 'auto commit'"
          git "push"
        end
      end,
    })

    vim.cmd.cabbrev("O", "Obsidian")
    local map = require("utils").safe_keymap_set
    map("n", "<leader>fo", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian search" })
  end,
}
