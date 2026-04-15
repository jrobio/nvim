return {
  'danymat/neogen',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('neogen').setup {
      enabled = true,
      snippet_engine = 'luasnip',
      languages = {
        python = {
          template = {
            annotation_convention = 'numpydoc',
          },
        },
      },
    }
  end,
  keys = {
    {
      '<leader>ng',
      function()
        require('neogen').generate()
      end,
      desc = 'Generate Docstring',
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
