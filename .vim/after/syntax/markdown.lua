vim.opt_local.conceallevel = 2

vim.cmd([[syntax match todoCheckbox '\v\s*(-|\*)\s\[\s\]'hs=e-4 conceal cchar=]])
vim.cmd([[syntax match todoCheckbox '\v\s*(-|\*)\s\[X\]'hs=e-4 conceal cchar=]])
vim.cmd([[syntax match todoCheckbox '\v\s*(-|\*)\s\[-\]'hs=e-4 conceal cchar=☒]])
vim.cmd([[syntax match todoCheckbox '\v\s*(-|\*)\s\[\.\]'hs=e-4 conceal cchar=⊡]])
vim.cmd([[syntax match todoCheckbox '\v\s*(-|\*)\s\[o\]'hs=e-4 conceal cchar=⬕]])

vim.cmd([[
    syntax region markdownWikiLink matchgroup=markdownLinkDelimiter start="\[\[" end="\]\]" contains=markdownUrl keepend oneline concealends
]])

vim.cmd([[syntax region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\%(\_[^][]\|\[\_[^][]*\]\)*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart concealends]])

vim.cmd([[syntax region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained conceal]])
