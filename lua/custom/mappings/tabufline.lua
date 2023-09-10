local go_to_buf = function(index)
  return function()
    local tabufline = require "nvchad.tabufline"
    local bufs = tabufline.bufilter() or {}
    if bufs[index] then
      vim.cmd("buffer " .. bufs[index])
    end
  end
end

local tabufline_mappings = {
  n = {
    ["<leader>X"] = {
      function()
        require("nvchad.tabufline").closeOtherBufs()
      end,
      "Close all buffers",
    },
    ["<A-1>"] = { go_to_buf(1), "Go to buffer 1" },
    ["<A-2>"] = { go_to_buf(2), "Go to buffer 2" },
    ["<A-3>"] = { go_to_buf(3), "Go to buffer 3" },
    ["<A-4>"] = { go_to_buf(4), "Go to buffer 4" },
    ["<A-5>"] = { go_to_buf(5), "Go to buffer 5" },
    ["<A-6>"] = { go_to_buf(6), "Go to buffer 6" },
    ["<A-7>"] = { go_to_buf(7), "Go to buffer 7" },
    ["<A-8>"] = { go_to_buf(8), "Go to buffer 8" },
    ["<A-9>"] = { go_to_buf(9), "Go to buffer 9" },
    ["<A-0>"] = { go_to_buf(10), "Go to buffer 10" },
    ["<A-[>"] = {
      function()
        require("nvchad.tabufline").move_buf(-1)
      end,
      "Move buffer to the left",
    },
    ["<A-]>"] = {
      function()
        require("nvchad.tabufline").move_buf(1)
      end,
      "Move buffer to the right",
    },
  },
}

return tabufline_mappings
