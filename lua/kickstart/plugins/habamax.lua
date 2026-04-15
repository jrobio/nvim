return {
  {
    'ntk148v/habamax.nvim',
    priority = 1000,
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
      vim.cmd.colorscheme 'habamax'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
