return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
    'mfussenegger/nvim-dap-python', --optional
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  lazy = false,
  keys = {
    { ',v', '<cmd>VenvSelect<cr>' },
  },
  opts = {
    -- Your settings go here
  },
}
-- vim: ts=2 sts=2 sw=2 et
