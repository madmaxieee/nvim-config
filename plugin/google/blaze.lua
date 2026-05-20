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
