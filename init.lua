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

vim.keymap.set("n", ")", "<cmd>cnext<cr>", {noremap = true})
vim.keymap.set("n", "(", "<cmd>cprev<cr>", {noremap = true})
vim.keymap.set("n", "<Leader>h", "<cmd>nohlsearch<cr><cmd>lclose<cr><cmd>cclose<cr>")
vim.keymap.set("n", "<Bslash>", "<C-^>", {silent = true})

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "fuzzy,menu,popup"
-- redirect c-n completion to always be omnicomplete
vim.keymap.set("i", "<C-n>", "<C-x><C-o>", { noremap = true })
vim.keymap.set("i", "<C-p>", "<C-x><C-o>", { noremap = true })

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
require('mini.pick').setup({
    mappings = {
        choose_marked = '<C-q>',
    }
})
vim.keymap.set("n", "<C-p>", MiniPick.builtin.files)
vim.keymap.set("n", "<C-k>", function() MiniPick.builtin.files({tool = "fallback"}) end)
vim.keymap.set("n", "<Leader>g", MiniPick.builtin.grep_live)

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
vim.keymap.set("n", "<Leader>1", "<cmd>Oil<CR>")

-- PARINFER
vim.keymap.set("n", "<Leader>pi", "<cmd>ParinferToggle<CR>")

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
