local state_dir = vim.fn.stdpath "state"
if type(state_dir) == "table" then
  state_dir = state_dir[1]
end

return {
  cond = not require("modes").minimal_mode and not require("modes").difftool_mode,
  "folke/persistence.nvim",
  lazy = false,
  init = function()
    vim.opt.sessionoptions = {
      "buffers",
      "curdir",
      "folds",
      "help",
      "tabpages",
      "winsize",
      "globals",
    }

    local persistence_group = vim.api.nvim_create_augroup("Persistence", { clear = true })
    local home = vim.fn.expand "~"
    local disabled_dirs = {
      [home] = true,
      [home .. "/Downloads"] = true,
      ["/private/tmp"] = true,
      ["/tmp"] = true,
    }

    -- disable persistence for certain directories
    vim.api.nvim_create_autocmd("VimEnter", {
      group = persistence_group,
      callback = function()
        local cwd = vim.fn.getcwd()
        local persistence = require "persistence"
        if disabled_dirs[cwd] or vim.g.started_with_stdin then
          persistence.stop()
          return
        end
        local argv = vim.fn.argv()
        local argc = vim.fn.argc()
        if argc == 0 then
          persistence.load()
        elseif argc > 0 and vim.fn.isdirectory(argv[1]) == 1 then
          persistence.stop()
          vim.fn.chdir(argv[1])
          local file = persistence.current { branch = false }
          local file_branch = persistence.current { branch = true }
          if vim.fn.filereadable(file_branch) == 0 and vim.fn.filereadable(file) == 0 then
            require("oil").open(vim.fn.getcwd())
          else
            persistence.load()
          end
          persistence.start()
        else
          persistence.stop()
        end
      end,
      nested = true,
    })

    -- disable persistence if nvim started with stdin
    vim.api.nvim_create_autocmd("StdinReadPre", {
      group = persistence_group,
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceLoadPre",
      group = persistence_group,
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          -- close all buffers with ft="lazy"
          if vim.bo[buf].ft == "lazy" then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    })

    vim.api.nvim_create_autocmd("SessionLoadPost", {
      group = persistence_group,
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == "" and vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 0 then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
        vim.schedule(function()
          vim.cmd [[windo filetype detect]]
        end)
      end,
    })
  end,
  opts = {
    dir = vim.fn.expand(state_dir) .. "/sessions/",
    need = 1,
    branch = true,
  },
}
