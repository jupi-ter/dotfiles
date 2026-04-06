vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
local parser_install_path = vim.fn.stdpath("data") .. "/site"
vim.opt.rtp:prepend(parser_install_path)

require("lazy").setup({
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false, 
        build = ':TSUpdate'
    },
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    {
        "ej-shafran/compile-mode.nvim",
        branch = "latest",
        dependencies = { "nvim-lua/plenary.nvim" },
        init = function()
            vim.g.compile_mode = {
                default_command = {
                    c = "make run",
                    odin = "odin run .",
                },
                recompile_no_fail = true,
                input_word_completion = true, 
                bang_expansion = true,
            }
        end,
    },
    {
        'ludovicchabant/vim-gutentags',
        config = function()
            vim.g.gutentags_project_root = {'.git', '.root'}
            vim.g.gutentags_ctags_tagfile = '.tags'
        end
    }
})

vim.filetype.add({ extension = { c3 = "c3", c3i = "c3", odin = "odin", cs = "cs" } })

-- =========================
-- Basic settings
-- =========================
vim.g.termguicolors = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.hlsearch = false
vim.o.incsearch = true

vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"

vim.o.wrap = false
vim.o.list = true
vim.o.path = "**"

vim.o.tags = "./tags;,tags"

vim.cmd("colorscheme retrobox")

-- =========================
-- Keymaps
-- =========================
local map = vim.keymap.set

map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

-- line shifting
map('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', { silent = true })
map('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', { silent = true })

-- Ctrl+Backspace to delete word in Insert Mode
map("i", "<C-H>", "<C-W>", { noremap = true, silent = true })
map("i", "<C-BS>", "<C-W>", { noremap = true, silent = true })

-- compile mode
vim.keymap.set("n", "<leader>cc", "<cmd>Compile<CR>", { desc = "Compile" })
vim.keymap.set("n", "<leader>cr", "<cmd>Recompile<CR>", { desc = "Recompile" })

local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files)
map("n", "<leader>fg", builtin.live_grep)
map("n", "<leader>fb", builtin.buffers)

map("n", "gd", vim.lsp.buf.definition)
map("n", "K", vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>e", vim.diagnostic.open_float)

map("n", "<leader>i", "gg=G")

-- =========================
-- Completion (nvim-cmp)
-- =========================
local cmp = require("cmp")

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping.complete(), -- Fixed stray text here
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
        { name = "nvim_lsp" },
    },
})

-- =========================
-- LSP setup
-- =========================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- C/C++
vim.lsp.config("clangd", { capabilities = capabilities })
vim.lsp.enable("clangd")

-- C3
vim.lsp.config("c3_lsp", {
    cmd = { "c3lsp" }, 
    filetypes = { "c3", "c3i" },
    root_markers = { "project.json", ".git" },
    capabilities = capabilities,
})
vim.lsp.enable("c3_lsp")

-- Odin
vim.lsp.config("ols", {
    cmd = { "ols" },
    filetypes = { "odin" },
    root_markers = { "ols.json", ".git" },
    capabilities = capabilities,
    init_options = { enable_snippets = true }
})
vim.lsp.enable("ols")

-- OmniSharp Setup
local omnisharp_bin = vim.fn.expand("$HOME/.local/share/omnisharp/OmniSharp")

vim.lsp.config("omnisharp", {
    -- The --languageserver flag is REQUIRED for standalone OmniSharp
    -- The -z flag tells it to use the "Stdio" mode which is what Neovim expects
    cmd = { omnisharp_bin, "--languageserver" , "-z" },
    capabilities = capabilities,
    filetypes = { "cs", "vb" },
    -- 0.11 Nightly root_markers: Exact filenames only! No wildcards.
    -- These markers tell Nvim "This folder is a C# project"
    root_markers = { ".git", ".sln", "obj", "bin" },
    settings = {
        sdk = {
            version = "8.0" 
        },
        omnisharp = {
            useModernNet = true,
            --enableDecompilationSupport = false,
            --analyzeOpenDocumentsOnly = true,
            enableMsBuildLoadProjectsOnDemand = false,
            enableEditorConfigSupport = true,
        }
    }
})

-- Safety: Only enable if the binary actually exists
if vim.fn.executable(omnisharp_bin) == 1 then
    vim.lsp.enable("omnisharp")
else
    print("OmniSharp binary not found at " .. omnisharp_bin)
end

-- ==========================
-- Autosave
-- ==========================
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        -- Note: Nightly 0.11 prefers vim.api.nvim_get_option_value("modified", {buf = bufnr})
        if vim.api.nvim_buf_get_option(bufnr, "modified") then
            vim.lsp.buf.format({ async = false })
            vim.cmd("silent! update")
        end
    end,
})

-- =========================
-- Auto highlight TS
-- =========================
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c3', 'c3i', 'c', 'lua', 'odin', 'cs' },
    callback = function() 
        vim.treesitter.start() 
    end,
})
