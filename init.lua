vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4 -- default tab stop
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.confirm = true

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "fuzzy,menu,popup"

function file_is_in_taitterm(file_path)
   if file_path == "" then return false end
   local dir = vim.fs.dirname(file_path)
   print(dir)

   local match = vim.fs.find("TaitTerm_Application", {
      path = dir,
      upward = true,
      stop = vim.fn.expand("~"),
   })
   return #match > 0
end

local on_taitterm_file_augroup = vim.api.nvim_create_augroup("on_taitterm_file", {})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
   group = on_taitterm_file_augroup,
   pattern = "*",
   callback = function(args)
      if file_is_in_taitterm(vim.fn.fnamemodify(args.file, ":p")) then
          -- Put local options for TaitTerm firmware in here
          vim.opt_local.tabstop = 3
          vim.opt_local.shiftwidth = 3
      end
   end
})


vim.keymap.set("n", ")", "<cmd>cnext<cr>",
    { noremap = true, desc = "next quickfix item" })
vim.keymap.set("n", "(", "<cmd>cprev<cr>",
    { noremap = true, desc = "prev quickfix item" })

vim.keymap.set("n", "<Leader>h", "<cmd>nohlsearch<cr><cmd>lclose<cr><cmd>cclose<cr>",
    { desc = "close all search things" })

vim.keymap.set("n", "<Bslash>", "<C-^>",
    { silent = true, desc = "swap to previous file" })

vim.keymap.set("n", "<Leader>bl", function()
    local cmd = string.format(
        "hg annotate -wbBZ -undq -r 'wdir()' '%s'",
        vim.fn.expand("%:p"))
    local out = vim.fn.system(cmd)
    local lines = vim.split(out, "\n")
    local line_blame = lines[vim.fn.line(".")] or "No blame available"
    print(vim.trim(line_blame))
end, { desc = "hg blame current line"})

vim.keymap.set("n", "<Leader>bf", function()
    local output = vim.fn.systemlist("hg annotate -undql " .. vim.fn.expand("%:p"))
    vim.cmd("new")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false

    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
    vim.bo.filetype = "hgannotate"
end, { desc = "hg blame file" })

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
    window = {
       config = function()
          local w = vim.o.columns
          local h = vim.o.lines
          return {
             anchor = "NW",
             border = "none",
             row = 0,
             col = 0,
             width = w,
             height = h,
          }
       end,
    },
})

-- rg doesn't support mercurial, so we need to DIY if we see a .hg directory
function files_with_hg()
    if vim.fn.isdirectory(".hg") == 1 then
        mp.builtin.cli({ command = { "hg", "files" } }, { source = { name = "Files" } })
    else mp.builtin.files() end
end

function files_without_ignore()
    -- could pass --hidden to rg here to really get all files (including
    -- .hg+.git blobs etc) but I rarely want that
    mp.builtin.cli(
        { command = { "rg", "--files", "--no-ignore",}, },
        { source = { name = "Files (no ignore)" } })
end

vim.keymap.set("n", "<C-p>", files_with_hg, { desc = "pick files" })
vim.keymap.set("n", "<C-q>", files_without_ignore, { desc = "pick files without ignore" })
vim.keymap.set("n", "<C-k>", function() MiniPick.builtin.files({tool = "fallback"}) end,
    { desc = "pick files (dumb)" })

vim.keymap.set("n", "<Leader>g",
    function()
        MiniPick.builtin.grep_live({globs = { "!bld/**" }})
    end,
    { desc = "live grep" }
)

-- OIL
local function prompt_yank_path()
    local oil = require("oil")
    local actions = require("oil.actions")
    local full_path = vim.fn.fnamemodify(oil.get_current_dir() .. oil.get_cursor_entry().name, ":p")
    local choices = {
        { label = "Full path",       modify = ":p" },
        { label = "CWD relative", modify = ":~:." },
        { label = "Filename only",   modify = ":t" },
    }
    vim.ui.select(choices, {
        prompt = "Yank path:",
        format_item = function(item)
            return item.label .. " (" .. vim.fn.fnamemodify(full_path, item.modify) .. ")"
        end,
    }, function(choice)
        if not choice then return end
        actions.yank_entry.callback({ modify = choice.modify })
    end)
end

require("oil").setup({
    keymaps = {
        ["yp"] = prompt_yank_path,
        ["Y"] = prompt_yank_path,
        ["<C-r>"] = "actions.refresh",
        ["<Leader>1"] = "actions.close",
        ["<Tab>"] = "actions.preview",
        ["?"] = "actions.show_help",
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
    float = {
        preview_split = "right",
    },
})
vim.keymap.set("n", "<Leader>1", "<cmd>Oil --float<CR>",
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
