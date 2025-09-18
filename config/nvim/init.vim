" Vim plugins
call plug#begin()

Plug 'Mofiqul/dracula.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/vim-vsnip'
Plug 'CRAG666/code_runner.nvim'
Plug 'windwp/nvim-autopairs'

call plug#end()

" Initial vim config
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set clipboard+=unnamedplus
syntax on
filetype plugin indent on

" Theme
colorscheme dracula

" Keybinds
vnoremap <C-c> "+y
vnoremap <C-v> "+p
nnoremap <C-/> :RunCode

" nvim .lua scripts
lua << EOF
-- Define language servers to install and configure
local servers = {
  "lua_ls",
  "clangd",
  "pyright",
  "ts_ls",
}

-- Code runner config
require('code_runner').setup({
  filetype = {
    python = "python3 -u",
    cpp = {
      "cd $dir &&",
      "g++ -std=c++17 $fileName -o $fileNameWithoutExt &&",
      "./$fileNameWithoutExt"
    },
    java = "javac % && java %<",
    rust = {
      "cd $dir &&",
      "rustc $fileName &&",
      "$dir/$fileNameWithoutExt"
    },
  },
})

-- Treesitter config
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "typescript", "cpp" },
  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true
  },
}

-- Mason and Mason-LSPconfig config
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = servers,
})

-- Set up lspconfig
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities
  })
end

-- nvim-autopairs configuration
require("nvim-autopairs").setup({})

-- Set up nvim-cmp config
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require'cmp'

cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done()
)

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

EOF
