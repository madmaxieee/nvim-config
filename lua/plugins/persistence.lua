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

    local function get_current_session()
      local persistence = require "persistence"
      local file = persistence.current()
      if vim.fn.filereadable(file) == 0 then
        file = persistence.current { branch = false }
      end
      return file
    end

    local function has_session()
      return vim.fn.filereadable(get_current_session()) == 1
    end

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
        local persistence_did_load = false
        if argc == 0 then
          persistence.load()
          persistence_did_load = has_session()
        elseif argc > 0 and vim.fn.isdirectory(argv[1]) == 1 then
          persistence.stop()
          vim.fn.chdir(argv[1])
          if not has_session() then
            require("oil").open(vim.fn.getcwd())
          else
            persistence.load()
            persistence_did_load = true
          end
          persistence.start()
        else
          persistence.stop()
        end
        if not persistence_did_load then
          -- also triggers SessionLoadPost autocmd if no session was loaded
          vim.api.nvim_exec_autocmds("SessionLoadPost", {})
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
        vim.schedule(function()
          vim.cmd [[tabdo windo filetype detect]]
        end)
      end,
    })

    vim.api.nvim_create_user_command("PersistenceDelete", function()
      local persistence = require "persistence"
      persistence.stop()
      vim.fs.rm(get_current_session(), { force = true })
    end, {})
  end,
  opts = {
    dir = vim.fn.expand(state_dir) .. "/sessions/",
    need = 1,
    branch = true,
  },
}
