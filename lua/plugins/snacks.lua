---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<Down>"] = { "history_forward", mode = { "i", "n" } },
            ["<Up>"] = { "history_back", mode = { "i", "n" } },

            ["<PageDown>"] = { "preview_scroll_down" },
            ["PageUp"] = { "preview_scroll_up" },

            ["J"] = { "preview_scroll_down" },
            ["K"] = { "preview_scroll_up" },
          }
        },
      }
    }
  }
}
