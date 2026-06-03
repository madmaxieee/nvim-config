if not require("flags").in_google3 then
  return {}
end

local map = require("utils").safe_keymap_set

map("n", "<leader>bl", function()
  require("blaze").blaze()
end, { desc = "Blaze (auto detect command)" })

map("n", "<leader>bt", function()
  require("blaze").blaze("test")
end, { desc = "Blaze test" })

map("n", "<leader>bb", function()
  require("blaze").blaze("build")
end, { desc = "Blaze build" })

map("n", "<leader>bc", function()
  require("blaze").blaze("coverage")
end, { desc = "Blaze coverage" })

map("n", "<leader>bat", function()
  require("blaze").blaze_all("test")
end, { desc = "Blaze all test" })

map("n", "<leader>bab", function()
  require("blaze").blaze_all("build")
end, { desc = "Blaze all build" })

vim.api.nvim_create_user_command("Blaze", function(opts)
  local cmd_type = opts.args ~= "" and opts.args or nil
  require("blaze").blaze(cmd_type)
end, {
  nargs = "?",
  complete = function()
    return { "build", "test", "coverage", "run" }
  end,
})

vim.api.nvim_create_user_command("BlazeAll", function(opts)
  local cmd_type = opts.args ~= "" and opts.args or "build"
  require("blaze").blaze_all(cmd_type)
end, {
  nargs = "?",
  complete = function()
    return { "build", "test" }
  end,
})
