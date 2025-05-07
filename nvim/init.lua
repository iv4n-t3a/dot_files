local indent = 2
vim.opt.encoding = 'UTF-8'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.shiftwidth = indent
vim.opt.softtabstop = indent
vim.opt.tabstop = indent
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.exrc = true
vim.opt.mouse = 'a'
vim.opt.swapfile = false
vim.opt.cursorline = false
vim.opt.cursorcolumn = false
vim.opt.termguicolors = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 400

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Packer manages itself

  use 'ap/vim-css-color'
  use 'csexton/trailertrash.vim'
  use 'mg979/vim-visual-multi'
  use 'akinsho/git-conflict.nvim'
  use 'ryanoasis/vim-devicons'
  use 'nvim-tree/nvim-tree.lua'
  use 'stevearc/aerial.nvim'
  use 'tpope/vim-surround'
  use 'tomtom/tcomment_vim'
  use 'Raimondi/delimitMate'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'jvgrootveld/telescope-zoxide'
  use 'tikhomirov/vim-glsl'
  use 'themercorp/themer.lua'
  use 'nvim-treesitter/nvim-treesitter'
  use 'aruyu/nvim-indentconfig'
  use { 'neoclide/coc.nvim', branch = 'release' }
  use 'MarcHamamji/runner.nvim'
  use 'zbirenbaum/copilot.lua'
  use 'olimorris/codecompanion.nvim'
  use 'nvimdev/dashboard-nvim'
  use 'lewis6991/gitsigns.nvim'
end)

require('copilot').setup {}
require('codecompanion').setup {}
require('aerial').setup {}
require('runner').setup {}

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "cpp", "python", "dart", "c", "go", "asm", "latex", "rust", "html", "css",
    "json", "yaml", "toml" -- configs
  },
}
require('lualine').setup {
  options = { theme = require 'lualine.themes.powerline_dark' },
}
require('themer').setup {
  colorscheme = 'onedark',
}
require('nvim-tree').setup {
  git = {
    enable = true,
  },
}
require("nvim-indentconfig").setup {
  default = {
    expandtab = true,
    size = 2
  },

  exclusions = {
    {
      expandtab = false,
      size = 8,
      filetype = { 'make' }
    },
    {
      expandtab = true,
      size = 4,
      filetype = { 'python' }
    },
  },
}
require('dashboard').setup {
  theme = 'hyper',
  config = {
    week_header = {
      enable = true,
    },
    shortcut = {
      { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
      {
        icon = ' ',
        icon_hl = '@variable',
        desc = 'Files',
        group = 'Label',
        action = 'Telescope find_files',
        key = 'f',
      },
      {
        desc = ' Apps',
        group = 'DiagnosticHint',
        action = 'Telescope app',
        key = 'a',
      },
      {
        desc = ' dotfiles',
        group = 'Number',
        action = 'Telescope dotfiles',
        key = 'd',
      },
    },
  },
}

require('gitsigns').setup {
  vim.keymap.set('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal({ ']c', bang = true })
    else
      require('gitsigns').nav_hunk('next')
    end
  end),

  vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal({ '[c', bang = true })
    else
      require('gitsigns').nav_hunk('prev')
    end
  end),

  vim.keymap.set('n', '<space>lb', require('gitsigns').toggle_current_line_blame),
  vim.keymap.set('n', '<space>wd', require('gitsigns').toggle_word_diff),
}

-- to not mistype
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Q', 'q', {})

vim.api.nvim_create_user_command('Blame', 'Gitsigns blame', {})

vim.api.nvim_create_user_command('Ai', function(opts)
  vim.cmd('CodeCompanionChat ' .. opts.args)
end, { nargs = '*' })

vim.keymap.set('n', 'q', ':q!<CR>', { noremap = true, silent = true })
vim.keymap.set('n', ',', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'n', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<space>t', ':AerialOpen<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 't', ':AerialNavOpen<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-J>', ':tabnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-K>', ':tabprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'z', ':w', { noremap = true, silent = true, callback = require('runner').run })
vim.keymap.set('n', 'cd', require('telescope').extensions.zoxide.list)

-- Telescope
vim.keymap.set('n', '<space>f', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<space>g', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<space>b', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<space>h', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })

-- Coc
vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { noremap = true, silent = true })
vim.keymap.set('n', 'gy', '<Plug>(coc-type-definition)', { noremap = true, silent = true })
vim.keymap.set('n', 'gi', '<Plug>(coc-implementation)', { noremap = true, silent = true })
vim.keymap.set('n', 'gr', '<Plug>(coc-references)', { noremap = true, silent = true })
vim.keymap.set('n', 'f', '<Plug>(coc-format)', { noremap = true, silent = true })
vim.keymap.set('n', 'F', '<Plug>(coc-format-selected)', { noremap = true, silent = true })
vim.keymap.set('n', '<space>r', '<Plug>(coc-rename)', { noremap = true, silent = true })
vim.keymap.set('n', '<space>i', ':CocCommand document.toggleInlayHint<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<space><tab>', ':CocCommand clangd.switchSourceHeader<CR>',
  { noremap = true, silent = true })
vim.g.coc_snippet_next = '<tab>'

function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
vim.keymap.set('i', '<TAB>', 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
  opts)
vim.keymap.set('i', '<C-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
vim.keymap.set('i', '<cr>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- trailertrash

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  command = 'TrailerTrim'
})

-- colorcolumn

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*.c', '*.cpp', '*.py' },
  callback = function()
    vim.api.nvim_set_option_value('colorcolumn', '80', {})
  end
})

-- delimitmate

vim.g.delimitMate_autoclose = 1
vim.g.delimitMate_jump_expansion = 1
vim.g.delimitMate_expand_space = 1
vim.g.delimitMate_expand_cr = 2
vim.g.delimitMate_expand_inside_quotes = 0

-- tex

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*.tex' },
  callback = function()
    vim.keymap.set('n', 'z', ':CocCommand latex.Build<CR>', { noremap = true, silent = true })
  end
})
