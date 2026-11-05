-- Only strings, constants, comments and definitions get color. Everything else is plain text.
local c = {
    bg         = "#161D1E",
    fg         = "#CECECE",
    punct      = "#708B8D", -- dimmed punctuation
    keyword    = "#A9B4B5", -- a little dimmer than fg
    string     = "#95CB82",
    constant   = "#CC8BC9", -- numbers, booleans, nil, constants
    comment    = "#DFDF8E", -- comments are worth reading, so make them bright
    definition = "#71ADE7", -- function/method definitions
    -- diffs: text color + a faint tint of it over bg (same layout as rose-pine)
    add        = "#95CB82", add_bg    = "#2F4032",
    change     = "#E5C07B", change_bg = "#3F3E31", change_text_bg = "#695E43",
    delete     = "#E06C75", delete_bg = "#3E2D2F",
    context_bg = "#212A2B",
}

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "theme"

local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

hl("Normal", { fg = c.fg, bg = c.bg })

-- plain: base groups that treesitter/LSP groups link to
for _, g in ipairs({ "Operator", "Type", "Identifier", "PreProc",
    "Define", "Macro", "PreCondit", "Special", "SpecialChar", "Tag", "Title",
    "@variable", "@function.call", "@function.method.call", "@constructor", "@module",
    "@lsp.type.function", "@lsp.type.method", "@lsp.type.parameter" }) do
    hl(g, {})
end

-- keywords: slightly dimmer than plain text
for _, g in ipairs({ "Statement", "Keyword", "Conditional", "Repeat", "Label", "Exception",
    "StorageClass", "Structure", "Typedef", "Include" }) do
    hl(g, { fg = c.keyword })
end

hl("Comment",   { fg = c.comment })
hl("String",    { fg = c.string })
hl("Constant",  { fg = c.constant })   -- Number/Boolean/Character/Float link here by default
hl("Function",  { fg = c.definition }) -- treesitter @function = definitions
hl("@lsp.typemod.function.declaration", { link = "Function" })
hl("@lsp.typemod.method.declaration",   { link = "Function" })
-- variable declarations (not uses): treesitter only knows parameters, LSP knows all
hl("@variable.parameter", { link = "Function" })
hl("@lsp.typemod.variable.declaration",  { link = "Function" })
hl("@lsp.typemod.parameter.declaration", { link = "Function" })
hl("Delimiter", { fg = c.punct })
hl("@punctuation", { fg = c.punct })

-- diffs (:diffthis and mini.diff)
hl("DiffAdd",    { bg = c.add_bg })
hl("DiffChange", { bg = c.change_bg })
hl("DiffDelete", { bg = c.delete_bg })
hl("DiffText",   { bg = c.change_text_bg })
hl("MiniDiffSignAdd",     { fg = c.add })
hl("MiniDiffSignChange",  { fg = c.change })
hl("MiniDiffSignDelete",  { fg = c.delete })
hl("MiniDiffOverAdd",     { fg = c.add, bg = c.add_bg })
hl("MiniDiffOverChange",  { fg = c.change, bg = c.change_bg })
hl("MiniDiffOverDelete",  { fg = c.delete, bg = c.delete_bg })
hl("MiniDiffOverContext", { bg = c.context_bg })
