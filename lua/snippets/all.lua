local status, ls = pcall(require, 'luasnip')

if not status then
  print('Something went wrong: ', ls)
  return {}
end

-- some shorthands...
local snippet = ls.snippet
local snippet_node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamic = ls.dynamic_node
local restore = ls.restore_node
local lambda = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local partial = require("luasnip.extras").partial
local match = require("luasnip.extras").match
local nonempty = require("luasnip.extras").nonempty
local dynamic_lambda = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

local autosnippet = ls.extend_decorator.apply(snippet, { snippetType = "autosnippet" })

local date = function() return {os.date('%Y-%m-%d')} end

-- snippets are added via ls.add_snippets(filetype, snippets[, opts]), where
-- opts may specify the `type` of the snippets ("snippets" or "autosnippets",
-- for snippets that should expand directly after the trigger is typed).
-- Add `snippetType = autosnippet` to filetype param make auto snippet
--
-- opts can also specify a key. By passing an unique key to each add_snippets, it's possible to reload snippets by
-- re-`:luafile`ing the file in which they are defined (eg. this one).
ls.add_snippets("all", {
  snippet("date", { func(date,{}) }),
})

local tex = require('snippets.utils.conditions')

local generate_fraction = function (_, snip)
    local stripped = snip.captures[1]
    local depth = 0
    local j = #stripped
    while true do
        local c = stripped:sub(j, j)
        if c == "(" then
            depth = depth + 1
        elseif c == ")" then
            depth = depth - 1
        end
        if depth == 0 then
            break
        end
        j = j - 1
    end
    return snippet_node(nil,
        fmta([[
        <>\frac{<>}{<>}
        ]],
        { text(stripped:sub(1, j-1)), text(stripped:sub(j)), insert(1)}))
end


ls.add_snippets("tex", {
  snippet({trig = "it", desr = "Expands to \\textit"},
    fmta("\\textit{<>}", {insert(1)} )),

  snippet({trig = "bf", desr = "Expands to \\textbf"},
    fmta("\\textbf{<>}", {insert(1)} )),

  snippet({trig = "tt", desr = "Expands to \\texttt"},
    fmta("\\texttt{<>}", {insert(1)} )),

  snippet({trig = "mk", descr = "Inline math"},
    fmta("$<>$ <>", {insert(1), insert(0)}) ),

  snippet({trig = "dm", descr = "Display math"},
    fmt(
      [[
      \[
        <>
      \]
      <>
      ]], {insert(1), insert(2)}, {delimiters = "<>"})),

  snippet( {trig = "align", descr = "Align math"},
    fmta([[
    \begin{align<>}
    <>
    \end{align<>}
    ]], {choice(1, {text("*"), text(""), text("ed")}), insert(2), rep(1) }),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),

  snippet({ trig = "cases", name = "cases", dscr = "cases", regTrig = true, hidden = false},
    fmta([[
    \begin{cases}
    <>
    \end{cases}
    ]],
    { insert(1) }),
	  { condition = tex.in_math, show_condition = tex.in_math }
	),

	snippet({ trig = "frac", name = "fraction", descr = "fraction (general)" },
	  fmta([[
	  \frac{<>}{<>}<>
	  ]], { insert(1), insert(2), insert(0) }),
	  { condition = tex.in_math, show_condition = tex.in_math }
  ),

  autosnippet({ trig="((\\d+)|(\\d*)(\\\\)?([A-Za-z]+)((\\^|_)(\\{\\d+\\}|\\d))*)\\/", name='fraction', dscr='auto fraction 1', trigEngine="ecma"},
    fmta([[
    \frac{<>}{<>}<>
    ]],
    { func(function (_, snip)
        return snip.captures[1]
      end), insert(1), insert(0) }),
    { condition = tex.in_math, show_condition = tex.in_math }),

  autosnippet({ trig='(^.*\\))/', name='fraction', dscr='auto fraction 2', trigEngine="ecma" },
    { dynamic(1, generate_fraction) },
    { condition=tex.in_math, show_condition=tex.in_math }),

  autosnippet({trig = "lim"}, fmta("\\lim<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "sum"}, fmta("\\sum<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "prod"}, fmta("\\prod<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "int"}, fmta("\\int<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "lm"}, fmta("\\limits_{<>}^{<>}", {insert(1), insert(2)}), {condition = tex.in_math, show_condition = tex.in_math} ),

  -- common math functions
  autosnippet({trig = "arcsin"}, fmta("\\arcsin<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "sin"},    fmta("\\sin<>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "arccos"}, fmta("\\arccos<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "cos"},    fmta("\\cos<>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "arctan"}, fmta("\\arctan<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "tan"},    fmta("\\tan<>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "log"},    fmta("\\log<>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "ln"},     fmta("\\ln<>", {insert(1)}),     {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "exp"},    fmta("\\exp<>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "argmax"}, fmta("\\argmax<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "argmin"}, fmta("\\argmin<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),

  -- Greek letters
  autosnippet({trig = "@a",        descr = "α"},       fmta("\\alpha<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@b",        descr = "β"},       fmta("\\beta<>", {insert(1)}),          {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@g",        descr = "γ"},       fmta("\\gamma<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@G",        descr = "Γ"},       fmta("\\Gamma<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@d",        descr = "δ"},       fmta("\\delta<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@D",        descr = "Δ"},       fmta("\\Delta<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@e",        descr = "ε"},       fmta("\\varepsilon<>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
      snippet({trig = "eps",       descr = "ε"},       fmta("\\epsilon<>", {insert(1)}),       {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@z",        descr = "ζ"},       fmta("\\zeta<>", {insert(1)}),          {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@eta",      descr = "η"},       fmta("\\eta<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@theta",    descr = "θ"},       fmta("\\theta<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
      snippet({trig = "theta",     descr = "θ"},       fmta("\\vartheta<>", {insert(1)}),      {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@Theta",    descr = "Θ"},       fmta("\\Theta<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@i",        descr = "iota"},    fmta("\\iota<>", {insert(1)}),          {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@k",        descr = "κ"},       fmta("\\kappa<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@l",        descr = "λ"},       fmta("\\lambda<>", {insert(1)}),        {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@m",        descr = "μ"},       fmta("\\mu<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@n",        descr = "ν"},       fmta("\\nu<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@x",        descr = "ξ"},       fmta("\\xi<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@X",        descr = "Xi"},      fmta("\\Xi<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "pi",        descr = "π"},       fmta("\\pi<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@Pi",       descr = "Pi"},      fmta("\\Pi<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@r",        descr = "ρ"},       fmta("\\rho<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "ro",        descr = "ro"},      fmta("\\varrho<>", {insert(1)}),        {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@s",        descr = "σ"},       fmta("\\sigma<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@S",        descr = "Σ"},       fmta("\\Sigma<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@tau",      descr = "τ"},       fmta("\\tau<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@u",        descr = "υ"},       fmta("\\upsilon<>", {insert(1)}),       {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@U",        descr = "Upsilon"}, fmta("\\Upsilon<>", {insert(1)}),       {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@f",        descr = "φ"},       fmta("\\phi<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
      snippet({trig = "@vf",       descr = "φ"},       fmta("\\varphi<>", {insert(1)}),        {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@F",        descr = "Phi"},     fmta("\\Phi<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@chi",      descr = "χ"},       fmta("\\chi<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@psi",      descr = "Ψ"},       fmta("\\psi<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@Psi",      descr = "Psi"},     fmta("\\Psi<>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@o",        descr = "ω"},       fmta("\\omega<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "@O",        descr = "Ω"},       fmta("\\Omega<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),

  -- indexes
  autosnippet({trig = "_",  regTrig = false, wordTrig = false}, fmta("_{<>}<>", {insert(1), insert(2)}), {condition = tex.in_math, show_condition = tex.in_math}),
  autosnippet({trig = "%^", regTrig = false, wordTrig = false}, fmta("^{<>}<>", {insert(1), insert(2)}), {condition = tex.in_math, show_condition = tex.in_math}),

  -- arrows
  autosnippet({trig = "->"},    fmta("\\to<>", {insert(1)}),                 {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "=>"},    fmta("\\implies<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "<->"},   fmta("\\Longleftrightarrow<>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "-up"},   fmta("\\uparrow<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "-Up"},   fmta("\\Uparrow<>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "-down"}, fmta("\\downarrow<>", {insert(1)}),          {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "-Down"}, fmta("\\Downarrow<>", {insert(1)}),          {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "!>"},    fmta("\\mapsto<>", {insert(1)}),             {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "!!>"},   fmta("\\longmapsto<>", {insert(1)}),         {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "||"},    fmta("\\mid <>", {insert(1)}),               {condition = tex.in_math, show_condition = tex.in_math} ),

  -- miscellanious
  autosnippet({trig = "inf"},     fmta("\\infty<>", {insert(1)}),                   {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "all"},     fmta("\\forall<>", {insert(1)}),                  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "exist"},   fmta("\\exists<>", {insert(1)}),                  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "nexist"},  fmta("\\nexists<>", {insert(1)}),                 {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "nabla"},   fmta("\\nabla<>", {insert(1)}),                   {condition = tex.in_math, show_condition = tex.in_math} ),
      snippet({trig = "pt"},      fmta("\\partial<>", {insert(1)}),                 {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "nothing"}, fmta("\\varnothing<>", {insert(1)}),              {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "..."},     fmta("\\cdots <>", {insert(1)}),                  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "square"},  fmta("\\square <>", {insert(1)}),                 {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "bsquare"}, fmta("\\blacksquare <>", {insert(1)}),            {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "+-"},      fmta("\\pm <>", {insert(1)}),                     {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "-+"},      fmta("\\mp <>", {insert(1)}),                     {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "ovr"},     fmta("\\overline{<>}<>", {insert(1), insert(0)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "hat"},     fmta("\\hat{<>}<>", {insert(1), insert(0)}),      {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "what"},    fmta("\\widehat{<>}<>", {insert(1), insert(0)}),  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "bar"},     fmta("\\bar{<>}<>", {insert(1), insert(0)}),      {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "text"},    fmta("\\text{<>}<>", {insert(1), insert(0)}),     {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "NN"},      fmta("\\mathbb{N}<>", {insert(0)}),               {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "ZZ"},      fmta("\\mathbb{Z}<>", {insert(0)}),               {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "QQ"},      fmta("\\mathbb{Q}<>", {insert(0)}),               {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "RR"},      fmta("\\mathbb{R}<>", {insert(0)}),               {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "CC"},      fmta("\\mathbb{C}<>", {insert(0)}),               {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "OO"},      fmta("\\mathbb{O}<>", {insert(0)}),               {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "mbb"},     fmta("\\mathbb{<>}<>", {insert(1), insert(0)}),   {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "mcal"},    fmta("\\mathcal{<>}<>", {insert(1), insert(0)}),  {condition = tex.in_math, show_condition = tex.in_math} ),

  -- binary operations
  autosnippet({trig = "mul"},  fmta("\\cdot <>", {insert(1)}),  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "**"},   fmta("\\cdot <>", {insert(1)}),  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "xmul"}, fmta("\\times <>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "xx"},   fmta("\\times <>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),

  autosnippet({trig = "and",      descr = "∩"}, fmta("\\cap <>", {insert(1)}),      {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "or",       descr = "∪"}, fmta("\\cup <>", {insert(1)}),      {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "subset",   descr = "⊂"}, fmta("\\subset <>", {insert(1)}),   {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "subseteq", descr = "⊆"}, fmta("\\subseteq <>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),

  autosnippet({trig = "supset",   descr = "⊃"}, fmta("\\supset <>", {insert(1)}),   {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "supseteq", descr = "⊇"}, fmta("\\supseteq <>", {insert(1)}), {condition = tex.in_math, show_condition = tex.in_math} ),

      snippet({trig = "in",    descr = "∈"},    fmta("\\in <>", {insert(1)}),       {condition = tex.in_math, show_condition = tex.in_math} ),
      snippet({trig = "notin", descr = "∉"},    fmta("\\notin <>", {insert(1)}),    {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "~=",    descr = "≈"},    fmta("\\approx <>", {insert(1)}),   {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "===",   descr = "≡"},    fmta("\\equiv<>", {insert(1)}),     {condition = tex.in_math, show_condition = tex.in_math} ),

  -- signs
  autosnippet({trig = "<="},  fmta("\\leqslant <>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "<<"},  fmta("\\ll<>", {insert(1)}),                  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = ">="},  fmta("\\gg<>", {insert(1)}),                  {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = ">>"},  fmta("\\leqslant <>", {insert(1)}),           {condition = tex.in_math, show_condition = tex.in_math} ),
  autosnippet({trig = "vec"}, fmta("\\vec{<>} <>", {insert(1), insert(0)}), {condition = tex.in_math, show_condition = tex.in_math} ),
      snippet({trig = "det"}, fmta("\\det <>", {insert(1)}),                {condition = tex.in_math, show_condition = tex.in_math} ),
})
