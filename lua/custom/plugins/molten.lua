return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0',
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    ft = { 'markdown', 'quarto' },
    init = function()
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_enter_output_behavior = 'open_and_enter'
    end,
    config = function()
      vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { desc = 'evaluate operator', silent = true })
      vim.keymap.set('n', '<leader>os', ':noautocmd MoltenEnterOutput<CR>', { desc = 'open output window', silent = true })
      vim.keymap.set('n', '<leader>mi', ':MoltenInit<CR>', { desc = 'Initialize the plugin', silent = true })
      vim.keymap.set('n', '<leader>mr', ':MoltenRestart<CR>', { desc = 'Restart the kernel', silent = true })
      vim.keymap.set('n', '<leader>me', ':MoltenEvaluateOperator<CR>', { desc = 'run operator selection', silent = true })
      vim.keymap.set('n', '<leader>rl', ':MoltenEvaluateLine<CR>', { desc = 'evaluate line', silent = true })
      vim.keymap.set('n', '<leader>rr', ':MoltenReevaluateCell<CR>', { desc = 're-evaluate cell', silent = true })
      vim.keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { desc = 'execute visual selection', silent = true })
      vim.keymap.set('v', '<leader>rv', ':<C-u>MoltenEvaluateVisual<CR>gv', { desc = 'evaluate visual selection', silent = true })
      vim.keymap.set('n', '<leader>oh', ':MoltenHideOutput<CR>', { desc = 'close output window', silent = true })
      vim.keymap.set('n', '<leader>md', ':MoltenDelete<CR>', { desc = 'delete Molten cell', silent = true })

      vim.keymap.set('n', '<localleader>ip', function()
        local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
        if venv ~= nil then
          -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
          venv = string.match(venv, '/.+/(.+)')
          vim.cmd(('MoltenInit %s'):format(venv))
        else
          vim.cmd 'MoltenInit python3'
        end
      end, { desc = 'Initialize Molten for python3', silent = true })

      local imb = function(e)
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()
          local try_kernel_name = function()
            local metadata = vim.json.decode(io.open(e.file, 'r'):read 'a')['metadata']
            return metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)
          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
            if venv ~= nil then
              kernel_name = string.match(venv, '/.+/(.+)')
            end
          end
          if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(('MoltenInit %s'):format(kernel_name))
          end
          vim.cmd 'MoltenImportOutput'
          vim.cmd 'QuartoActivate'
        end)
      end

      vim.api.nvim_create_autocmd('BufAdd', {
        pattern = { '*.ipynb' },
        callback = imb,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = { '*.ipynb' },
        callback = function(e)
          if vim.api.nvim_get_vvar 'vim_did_enter' ~= 1 then
            imb(e)
          end
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { '*.ipynb' },
        callback = function()
          if require('molten.status').initialized() == 'Molten' then
            vim.cmd 'MoltenExportOutput!'
          end
        end,
      })

      local default_notebook = [[{
        "cells": [
          {
            "cell_type": "markdown",
            "metadata": {},
            "source": [""]
          }
        ],
        "metadata": {
          "kernelspec": {
            "display_name": "Python 3",
            "language": "python",
            "name": "python3"
          },
          "language_info": {
            "codemirror_mode": {
              "name": "ipython"
            },
            "file_extension": ".py",
            "mimetype": "text/x-python",
            "name": "python",
            "nbconvert_exporter": "python",
            "pygments_lexer": "ipython3"
          }
        },
        "nbformat": 4,
        "nbformat_minor": 5
        }]]

      local function new_notebook(filename)
        local path = filename .. '.ipynb'
        local file = io.open(path, 'w')
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd('edit ' .. path)
        else
          print 'Error: Could not open new notebook file for writing.'
        end
      end

      vim.api.nvim_create_user_command('NewNotebook', function(opts)
        new_notebook(opts.args)
      end, {
        nargs = 1,
        complete = 'file',
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
