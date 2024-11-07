" Highlight word-diff syntax
syntax match gitDiffWordsAdded "{+.\{-}+}"
syntax match gitDiffWordsRemoved "\[\-.\{-}\-\]"
hi def link gitDiffWordsAdded diffAdded
hi def link gitDiffWordsRemoved diffRemoved
