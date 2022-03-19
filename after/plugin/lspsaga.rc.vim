if !exists('g:loaded_lspsaga') | finish | endif

lua << EOF
local saga = require 'lspsaga'

saga.init_lsp_saga {
  error_sign = '',
  warn_sign = '',
  hint_sign = '',
  infor_sign = '',
  border_style = "round",
}

EOF

nnoremap <silent><leader>gH <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
nnoremap <silent><leader>gs <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
nnoremap <silent><leader>gr <cmd>lua require('lspsaga.rename').rename()<CR>
" close rename win use <C-c> in insert mode or `q` in noremal mode or `:q`
nnoremap <silent><leader>gv <cmd>lua require'lspsaga.provider'.preview_definition()<CR>

nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>
" -- jump diagnostic
nnoremap <silent> [e :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> ]e :Lspsaga diagnostic_jump_prev<CR>
" Float terminal
nnoremap <silent> <C-t> <cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>
tnoremap <silent> <C-t> <C-\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>
