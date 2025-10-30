---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        list = {
          -- Навигация по списку (результатам)
          keys = {
            ["<PageDown>"] = { "preview_scroll_down", mode = { "n", "i" } },
            ["<PageUp>"]   = { "preview_scroll_up",   mode = { "n", "i" } },
            ["<Down>"]     = { "cycle_history_next", mode = "i" },
            ["<Up>"]       = { "cycle_history_prev", mode = "i" },
            ["<C-n>"]      = { "cycle_history_next", mode = "i" },
            ["<C-p>"]      = { "cycle_history_prev", mode = "i" },
          },
        },

        preview = {
          keys = {
            -- Скролл содержимого превью (аналог slow_scroll из Telescope)
            ["<Down>"] = { "preview_scroll_down", mode = { "n" } },
            ["<Up>"]   = { "preview_scroll_up",   mode = { "n" } },
            ["<Left>"] = { "preview_scroll_left", mode = { "n" } },
            ["<Right>"] = { "preview_scroll_right", mode = { "n" } },
          },
        },
      },

      -- Автокоманда для включения нумерации строк в превью (аналог TelescopePreviewerLoaded)
      on_init = function(picker)
        picker:on("opened", function()
          local win = picker.windows.preview
          if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_option_value("number", true, { win = win })
          end
        end)
      end,
    },
  },
}
