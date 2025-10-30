---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<Down>"] = { "history_forward", mode = { "i" } },
            ["<Up>"] = { "history_back", mode = { "i" } },

            ["<PageDown>"] = { "preview_scroll_down" },
            ["<PageUp>"] = { "preview_scroll_up" },

            ["J"] = { "preview_scroll_down" },
            ["K"] = { "preview_scroll_up" },
          }
        },
      }
    }
  }
}
