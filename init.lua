vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.ts = 4
vim.opt.sw = 4
vim.opt.expandtab = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.confirm = true

vim.keymap.set("n", ")", "<cmd>cnext<cr>",
    { noremap = true, desc = "next quickfix item" })
vim.keymap.set("n", "(", "<cmd>cprev<cr>",
    { noremap = true, desc = "prev quickfix item" })

vim.keymap.set("n", "<Leader>h", "<cmd>nohlsearch<cr><cmd>lclose<cr><cmd>cclose<cr>",
    { desc = "close all search things" })

vim.keymap.set("n", "<Bslash>", "<C-^>",
    { silent = true, desc = "swap to previous file" })

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "fuzzy,menu,popup"

local function try_omni_then_keyword_complete(kw_key)
  if vim.bo.omnifunc ~= "" then
      return "<C-x><C-o>"
  else
      return kw_key
  end
end

local function toggle_omni()
  if vim.bo.omnifunc ~= "" then
    vim.b._saved_omnifunc = vim.bo.omnifunc
    vim.bo.omnifunc = ""
    vim.notify("Omnicomplete disabled")
  else
    vim.bo.omnifunc = vim.b._saved_omnifunc or ""
    vim.notify("Omnicomplete enabled: " .. vim.bo.omnifunc)
  end
end

-- redirect c-n/c-p should be omni-complete if it exists, otherwise keyword complete
vim.keymap.set("i", "<C-n>", function() return try_omni_then_keyword_complete("<C-n>") end,
    { expr = true, noremap = true, desc = "omni or kewword complete" })
vim.keymap.set("i", "<C-p>", function() return try_omni_then_keyword_complete("<C-p>") end,
    { expr = true, noremap = true, desc = "omni or kewword complete" })

-- <L>o toggles omnicomplete
vim.keymap.set("n", "<leader>o", toggle_omni,
    { desc = "toggle omnicomplete" })

-- grepping
vim.opt.grepprg = "rg --vimgrep" -- by default this uses -uu flag which ignores gitignore
-- <L>s greps for word under cursor
vim.keymap.set("n", "<Leader>s", "\"jyiw:grep! <C-r><C-w><cr><cmd>cope<cr>",
    { silent = true, desc = "quickfix search word under cursor" })

-- <L>e toggles diagnostics
vim.keymap.set( "n", "<Leader>e", function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
    { silent = true, noremap = true, desc = "toggle diagnostics" })

vim.pack.add( {
    { src = "https://github.com/unblevable/quick-scope", version = "v2.7.1", },
    { src = "https://github.com/nvim-mini/mini.pick", version = "fe079c2bd894a5ee70b62f23d819620ef40c4949", },
    { src = "https://github.com/stevearc/oil.nvim", version = "v2.15.0", },
    { src = "https://github.com/gpanders/nvim-parinfer", version = "v1.2.0", },
    { src = "https://github.com/vlime/vlime", version = "e276e9a6f37d2699a3caa63be19314f5a19a1481", },
    { src = "https://github.com/neovim/nvim-lspconfig", },
    { src = "https://github.com/rose-pine/neovim", version = "v3.0.2", name = "rose-pine" },
})

-- COLORSCHEME
vim.cmd [[colorscheme rose-pine]]

-- MINI PICK
local mp = require('mini.pick')
mp.setup({
    mappings = {
        choose_marked = '<C-q>',
    },
    source = {
        show = mp.default_show,
    },
})
vim.keymap.set("n", "<C-p>", MiniPick.builtin.files,
    { desc = "pick files" })
vim.keymap.set("n", "<C-k>", function() MiniPick.builtin.files({tool = "fallback"}) end,
    { desc = "pick files (dumb)" })
vim.keymap.set("n", "<Leader>g", MiniPick.builtin.grep_live,
    { desc = "live grep" })

-- OIL
require("oil").setup({
    keymaps = {
        ["Y"] = "actions.yank_entry",
        ["<C-r>"] = "actions.refresh",
        ["<Leader>1"] = "actions.close",
        ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
                detail = not detail
                if detail then
                    require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
                else
                    require("oil").set_columns({ "icon" })
                end
            end,
        },
    },
    view_options = {
        show_hidden = true,
    },
})
vim.keymap.set("n", "<Leader>1", "<cmd>Oil<CR>",
    { desc = "open file browser" })

-- PARINFER
vim.keymap.set("n", "<Leader>pi", "<cmd>ParinferToggle<CR>",
    { desc = "toggle parinfer" })

-- VLIME
vim.g.vlime_compiler_policy = { DEBUG = 3 }
vim.g.vlime_leader = ","

-- LSP
-- The omnifunc was getting overridden sometimes. Not sure why
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.schedule(function()
            vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
        end)
    end,
})
vim.lsp.enable("basedpyright")
vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
