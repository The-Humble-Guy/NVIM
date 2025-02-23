return {
  "lervag/vimtex",
  lazy = false,
  -- tag = "v2.15" -- uncomment to pin to a specific release
  init = function ()
    -- VimTex configuration goes here, e.g
    vim.g.vimtex_view_method = "zathura"
    vim.g.tex_conceal = 'abdmg'
    vim.g.tex_flavor = "latex"
    vim.g.vimtex_compiler_output_directory = "build"
    -- vim.g.vimtex_syntax_conceal = {
    --   accents = 0,
    --   cites = 1,
    --   fancy = 0,
    --   greek = 1,
    --   math_bounds = 0,
    --   math_delimiters = 1,
    --   styles = 0,
    -- }
    -- vim.g.vimtex_syntax_conceal_enabled = 1
    -- vim.opt.conceallevel = 2  -- Показывать скрытые символы как замену (например, α вместо \alpha)
    -- vim.opt.concealcursor = 'nv'  -- Отображать символы в нормальном, визуальном режимах и режиме вставки
  end
}
