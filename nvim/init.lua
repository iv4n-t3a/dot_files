local indent = 2
vim.opt.encoding = 'UTF-8'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.shiftwidth = indent
vim.opt.softtabstop = indent
vim.opt.tabstop = indent
vim.opt.smarttab = true
vim.opt.exrc = true
vim.opt.expandtab = true
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
  use 'rafi/awesome-vim-colorschemes'
  use 'csexton/trailertrash.vim'
  use 'mg979/vim-visual-multi'
  use 'akinsho/git-conflict.nvim'
  use 'ryanoasis/vim-devicons'
  use 'preservim/nerdtree'
  use 'preservim/tagbar'

  use 'tpope/vim-surround'
  use 'https://tpope.io/vim/commentary.git'
  use 'Raimondi/delimitMate'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'jvgrootveld/telescope-zoxide'
  use 'tikhomirov/vim-glsl'
  use {'neoclide/coc.nvim', branch = 'release'}
  use { "catppuccin/nvim", as = "catppuccin" }
  use {
    'MarcHamamji/runner.nvim',
    requires = {
      'nvim-telescope/telescope.nvim',
      requires = { 'nvim-lua/plenary.nvim' }
    },
     config = function()
      require('runner').setup()
    end
  }
  -- use({
  --   "coffebar/neovim-project",
  --   config = function()
  --     vim.opt.sessionoptions:append("globals")
  --     require("neovim-project").setup {
  --       projects = {
  --         "~/Projects/*",
  --         "~/Sources/*",
  --       },
  --       picker = {
  --         type = "telescope",
  --       },
  --       datapath = vim.fn.stdpath("data"),
  --       last_session_on_startup = false,
  --       dashboard_mode = true,
  --       forget_project_keys = {
  --           i = "<C-d>",
  --           n = "d"
  --       }
  --     }
  --   end,
  --   requires = {
  --     { "nvim-lua/plenary.nvim" },
  --     { "nvim-telescope/telescope.nvim", tag = "0.1.4" },
  --     { "Shatur/neovim-session-manager" },
  --   }
  -- })
end)

require('lualine').setup {
  options = { theme  = require'lualine.themes.powerline_dark' },
}

vim.api.nvim_set_keymap('n', 'q', ':q!<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', ',', ':w<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'n', ':NERDTreeFocus<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 't', ':TagbarOpenAutoClose<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-J>', ':tabnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-K>', ':tabprevious<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'z', ':w', {noremap = true, silent = true, callback = require('runner').run})
vim.keymap.set("n", "cd", require("telescope").extensions.zoxide.list)

-- Telescope
vim.api.nvim_set_keymap('n', '<space>f', '<cmd>Telescope find_files<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<space>g', '<cmd>Telescope live_grep<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<space>b', '<cmd>Telescope buffers<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<space>h', '<cmd>Telescope help_tags<cr>', {noremap = true, silent = true})

-- Coc
vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gy', '<Plug>(coc-type-definition)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gi', '<Plug>(coc-implementation)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gr', '<Plug>(coc-references)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'f', '<Plug>(coc-format)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'F', '<Plug>(coc-format-selected)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<space>r', '<Plug>(coc-rename)', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<space>i', ':CocCommand document.toggleInlayHint<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<space><tab>', ':CocCommand clangd.switchSourceHeader<CR>', {noremap = true, silent = true})
vim.g.coc_snippet_next = '<tab>'

function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
vim.keymap.set("i", "<C-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- trailertrash

vim.api.nvim_create_autocmd({'BufWritePost'}, {
  command = "TrailerTrim"
})

-- colorcolumn

vim.api.nvim_create_autocmd({'BufEnter'}, {
  pattern = {'*.c', '*.cpp', '*.py'},
  callback = function()
    vim.api.nvim_set_option_value("colorcolumn", "80", {})
  end
})

-- delimitmate

vim.g.delimitMate_autoclose = 1
vim.g.delimitMate_jump_expansion = 1
vim.g.delimitMate_expand_space = 1
vim.g.delimitMate_expand_cr = 2
vim.g.delimitMate_expand_inside_quotes = 0

-- colorscheme

require("catppuccin").setup {
  color_overrides = {
    all = {
      base = "#161616",
    }
  }
}

vim.cmd.colorscheme "catppuccin"

-- tex

vim.api.nvim_create_autocmd({'BufEnter'}, {
  pattern = {'*.tex'},
  callback = function()
    vim.api.nvim_set_keymap('n', 'z', ':CocCommand latex.Build<CR>', {noremap = true, silent = true})
  end
})
