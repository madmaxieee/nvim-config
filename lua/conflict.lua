---@type {conflicted_files: table<string, boolean>}
local state = {}

---@param path string a directory or a single file
---@return table<string, boolean> conflicted files
local function detect_conflicted_files(path)
  local jobs = {
    vim.system({ "rg", "-l", "^<{7}", path }),
    vim.system({ "rg", "-l", "^={7}", path }),
    vim.system({ "rg", "-l", "^>{7}", path }),
  }

  local job_results = {}
  for i, job in ipairs(jobs) do
    job_results[i] = job:wait()
  end

  for _, result in pairs(job_results) do
    -- code 0 indicates a match was found
    if result.code ~= 0 then
      return {}
    end
  end

  local candidate_files = {}
  for _, result in ipairs(job_results) do
    for line in vim.gsplit(result.stdout, "\n") do
      if line ~= "" then
        candidate_files[line] = (candidate_files[line] or 0) + 1
      end
    end
  end

  local conflicted_files = {}
  for file, count in pairs(candidate_files) do
    if count == #jobs then
      conflicted_files[file] = true
    end
  end

  return conflicted_files
end

local augroup =
  vim.api.nvim_create_augroup("ConflictDetection", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  desc = "Detect conflicted files in the current working directory on startup",
  callback = function()
    state.conflicted_files = detect_conflicted_files(vim.fn.getcwd())
    vim.schedule(function()
      for file, _ in pairs(state.conflicted_files) do
        vim.notify(
          "Merge conflict detected in file: " .. file,
          vim.log.levels.WARN,
          { title = "Conflict Detection" }
        )
      end
    end)
  end,
})

-- TODO: add conflict marker highlighting
-- TODO: add commands to navigate between conflict markers
-- TODO: add snakcs picker to find conflict location
-- TODO: use LSP to provide code actions for resolving conflicts

-- for testing
--[[
<<<<<<< TARGET BRANCH
base content
target content
||||||| BASE
base content
=======
base content
source content
>>>>>>> SOURCE BRANCH
]]
