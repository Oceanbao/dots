if has("nvim")
  let g:plug_home = stdpath('data') . '/plugged'
endif

call plug#begin()

Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'tomasiser/vim-code-dark'
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim' " or other package manager

Plug 'ggandor/lightspeed.nvim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'cohama/lexima.vim'

" Plug 'itchyny/lightline.vim'
Plug 'sheerun/vim-polyglot'
Plug 'Yggdroot/indentLine'
Plug 'dense-analysis/ale'
Plug 'jiangmiao/auto-pairs'
Plug 'plasticboy/vim-markdown'

if has("nvim")
  Plug 'windwp/nvim-ts-autotag'
  Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
  " nvim-cmp
  " Plug 'hrsh7th/cmp-nvim-lsp'
  " Plug 'hrsh7th/cmp-buffer'
  " Plug 'hrsh7th/cmp-path'
  " Plug 'hrsh7th/cmp-cmdline'
  " Plug 'hrsh7th/nvim-cmp'
  " Plug 'L3MON4D3/LuaSnip'
  " Plug 'onsails/lspkind-nvim'

  Plug 'nvim-lualine/lualine.nvim'
  Plug 'kristijanhusak/defx-git'
  Plug 'kristijanhusak/defx-icons'
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'neovim/nvim-lspconfig'
  " Plug 'glepnir/lspsaga.nvim'
  Plug 'tami5/lspsaga.nvim', { 'branch': 'nvim6.0' }
  Plug 'folke/lsp-colors.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
endif

Plug 'groenewege/vim-less', { 'for': 'less' }

call plug#end()

