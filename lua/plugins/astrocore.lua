-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local filemanager = require("toggleterm.terminal").Terminal
local superfile = filemanager:new {
  cmd = "spf",
  hidden = true,
  direction = "float",
  on_open = function(term)
    if not term:is_open() then term:toggle() end
    term:change_dir(vim.fn.getcwd())
  end,
}

function superfile_toggle() superfile:toggle() end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        ["<Leader>lq"] = { "<cmd>LspStop<cr>", desc = "Turn off LSP on current buffer" },
        ["<Leader>ts"] = { function() superfile_toggle() end, desc = "Open Superfile filemanager" },
        ["<Leader>tt"] = { "<cmd>ToggleTerm direction=tab<cr>", desc = "ToggleTerm in new window" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      -- keymaps to move block of text right down or up
      v = {
        ["<Leader>f"] = {function ()
        -- NOTE: This function from this issue: https://github.com/nvim-telescope/telescope.nvim/issues/1923
          local get_visual_selection = function ()
            vim.cmd('noau normal! "vy"')
            local text = vim.fn.getreg('v')
            vim.fn.setreg('v', {})
            text = string.gsub(text, "\n", "")
            if #text > 0 then
              return text
            else
              return ''
            end
          end

          local text = get_visual_selection()

          require("snacks").picker.grep({
            search = text,
            live = true
          })

        end, desc = "Find selected text"},
        ["<A-j>"] = { ":m '>+1<CR>gv=gv"},
        ["<A-k>"] = { ":m '<-2<CR>gv=gv"},
        ["p"] = { '"_dP'},
      },
      x = {
        ["J"] = {":m '>+1<CR>gv=gv"},
        ["K"] = {":m '<-2<CR>gv=gv"},
        ["<A-j>"] = {":m '>+1<CR>gv=gv"},
        ["<A-k>"] = {":m '<-2<CR>gv=gv"},
      },
      t = {
        -- setting a mapping to false will disable it
        ["<esc>"] = { "<C-\\><C-n>" },
        ["<esc><esc>"] = { "<cmd>ToggleTermToggleAll<cr>" },
      },
    },
  },
}
