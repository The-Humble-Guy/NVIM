---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  opts = function (plugin, opts)
    local actions = require "telescope.actions"
    opts.defaults.mappings = {
      i = {
        ["<Down>"] = actions.cycle_history_next,
        ["<Up>"] = actions.cycle_history_prev,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<PageUp>"] = actions.move_selection_next,
        ["<PageDown>"] = actions.move_selection_previous,
      },
      n = {
        ["<C-Down>"] = actions.preview_scrolling_down,
        ["<C-Up>"] = actions.preview_scrolling_up,
        ["<Left>"] = actions.preview_scrolling_left,
        ["<Rigth>"] = actions.preview_scrolling_right,
      }
    }
  end
}
