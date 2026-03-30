-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- lsp. this will be deprecated at some point
    "neovim/nvim-lspconfig",

    -- Completion
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
})

-- =========================
-- Basic settings
-- =========================
vim.g.mapleader = " "
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

-- tags (ctags)
vim.o.tags = "./tags;,tags"

vim.cmd("colorscheme retrobox")

-- =========================
-- Keymaps (simple + useful)
-- =========================
local map = vim.keymap.set

-- window movement
map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

-- basic actions
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

-- line shifting
map('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', { silent = true })
map('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', { silent = true })

-- Telescope
local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files)
map("n", "<leader>fg", builtin.live_grep)
map("n", "<leader>fb", builtin.buffers)

-- LSP keymaps
map("n", "gd", vim.lsp.buf.definition)
map("n", "K", vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)

-- see error
map("n", "<leader>e", vim.diagnostic.open_float)

-- ctags navigation
map("n", "<C-]>", "<C-]>")
map("n", "<C-t>", "<C-t>")

-- Indent
map("n", "<leader>i", "gg=G")

-- =========================
-- Completion (nvim-cmp)
-- =========================
local cmp = require("cmp")

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
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
vim.lsp.config("clangd", {
    capabilities = capabilities,
})

vim.lsp.enable("clangd")

-- C3 (Using the AUR-installed c3-lsp)
vim.lsp.config("c3_lsp", {
    cmd = { "c3lsp" }, 
    filetypes = { "c3", "c3i" },
    root_markers = { "project.json", ".git" },
    capabilities = capabilities,
})

vim.lsp.enable("c3_lsp")

-- ==========================
-- Autosave
-- ==========================

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_option(bufnr, "modified") then
      vim.cmd("silent! update")
    end
  end,
})

