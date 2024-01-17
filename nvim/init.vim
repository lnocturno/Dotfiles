" Install vim-plugged if not already installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" PLUGINS
call plug#begin()

" Startup menu
Plug 'mhinz/vim-startify'
let g:startify_lists = [
	      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
	      \ { 'type': 'files',     'header': ['   MRU']            },
	      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
	      \ { 'type': 'sessions',  'header': ['   Sessions']       },
	      \ { 'type': 'commands',  'header': ['   Commands']       },
	      \ ]

let g:startify_bookmarks = [
	      \ '~/.config/nvim/init.vim',
	      \ ]

" Status Bar
Plug 'itchyny/lightline.vim'
set noshowmode
let g:lightline = {
	  \ 'enable': {'statusline': 1, 'tabline': 0},
	  \ 'colorscheme': 'nightfox',
	  \ 'active': {
	  \   'left': [ [ 'mode', 'paste' ],
	  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
	  \ },
	  \ 'component_function': {
	  \   'gitbranch': 'FugitiveHead'
	  \ },
	  \ }

let g:lightline.separator = {
	    \   'left': '', 'right': ''
      \}
let g:lightline.subseparator = {
	    \   'left': '', 'right': ''
      \}

" Powerline buffers
Plug 'mengelbrecht/lightline-bufferline'

let g:lightline.tabline = {'left': [ ['tabs'] ],'right': [ ['close'] ]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
set showtabline=2  " Show tabline
set guioptions-=e  " Don't use GUI tabline

" noremap <1><C-\><C-n>:1gt<cr>

Plug 'nvim-tree/nvim-web-devicons'

" FZF!
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
Plug 'ibhagwan/fzf-lua'
autocmd VimEnter * FzfLua setup_fzfvim_cmds

Plug 'dense-analysis/ale'

let g:ale_linters = { 'c': ['cppcheck', 'flawfinder'], }

let g:ale_fixers = { '*': ['remove_trailing_lines', 'trim_whitespace'] }
let g:ale_fix_on_save = 1

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Comments
Plug 'tpope/vim-commentary'

" Trailing symbols
Plug 'ntpeters/vim-better-whitespace'
let g:better_whitespace_enabled=1
" nnoremap <F4> :ToggleWhitespace<CR>

set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,extends:⟩,precedes:⟨
nnoremap <F3> :set list!<CR>

" GIT
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" File manager
Plug 'preservim/nerdtree'
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <F2> :NERDTreeToggle<CR>

Plug 'Yggdroot/indentLine'

let g:indentLine_leadingSpaceChar = '·'

let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indent_guides_auto_colors = 1
let g:indentLine_fileTypeExclude = ['fzf', 'startify', 'vim', 'txt']
nnoremap <F4> :LeadingSpaceToggle<CR>

Plug 'rhysd/git-messenger.vim'

" Tig plugin
Plug 'iberianpig/tig-explorer.vim'

" https://github.com/nvim-treesitter/nvim-treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Plug 'folke/which-key.nvim'

Plug 'dhananjaylatkar/cscope_maps.nvim'

" More colors!
Plug 'sjl/badwolf'
Plug 'gkapfham/vim-vitamin-onec'
Plug 'EdenEast/nightfox.nvim'

call plug#end()

lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['clangd'].setup {
    capabilities = capabilities
  }
EOF

lua require("cscope_maps").setup({cscope = {picker = "fzf-lua", skip_picker_for_single_result = true}})

lua<<EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    -- disable = function(lang, buf)
    --    local max_filesize = 100 * 1024 -- 100 KB
    --    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    --    if ok and stats and stats.size > max_filesize then
    --        return true
    --    end
    --end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

" add some numbers and highlighting!
set number
set relativenumber
syntax enable

set colorcolumn=100

" Highlighting
set termguicolors
set background=dark
colorscheme nightfox

set shiftwidth=8

" save 500 last commands
set history=500

" Turn off swap files
set noswapfile
set nobackup

" Turn on highlight on search
set hlsearch

" Work with terminal
let g:term_buf = 0
let g:term_win = 0

function! Term_toggle(height)
  if win_gotoid(g:term_win)
    hide
  else
    botright new
    exec "resize " . a:height
    try
      exec "buffer " . g:term_buf
      catch
        call termopen($SHELL, {"detach": 0})
        let g:term_buf = bufnr("")
      endtry
      startinsert!
      let g:term_win = win_getid()
  endif
  endfunction
  autocmd TermOpen * set nonumber

  nnoremap <F5> :call Term_toggle(20)<cr>
  tnoremap <F5><C-\><C-n>:call Term_toggle(20)<cr>
