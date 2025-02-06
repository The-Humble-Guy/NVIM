-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.gruvbox-baby" },
  { import = "astrocommunity.colorscheme.vscode-nvim" },
  { import = "astrocommunity.git.blame-nvim"},
  { import = "astrocommunity.scrolling.neoscroll-nvim"},
  { import = "astrocommunity.motion.mini-move" },
  -- import/override with your plugins folder
}
