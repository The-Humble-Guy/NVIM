---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  opts = function (plugin, opts)
    local state = require('telescope.state')
    local actions = require("telescope.actions")

    -- NOTE: This function from issue on GitGub: https://github.com/nvim-telescope/telescope.nvim/issues/2602
    local slow_scroll = function (prompt_bufnr, direction)
      local actions_state = require("telescope.actions.state")
      local previewer = actions_state.get_current_picker(prompt_bufnr).previewer
      local status = state.get_status(prompt_bufnr)

      -- Check if we actually have a previewer and a preview window
      if type(previewer) ~= "table" or previewer.scroll_fn == nil or status.preview_win == nil then
        return
      end

      previewer:scroll_fn(1 * direction)
    end

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
        ["<Left>"] = actions.preview_scrolling_left,
        ["<Rigth>"] = actions.preview_scrolling_right,
        ["<Down>"] = function (bufnr) slow_scroll(bufnr, 1) end,
        ["<Up>"] = function(bufnr) slow_scroll(bufnr, -1) end,
      }
    }
  end
}
