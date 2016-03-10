" Vim syntax file
" Language: OpenStack logfile
" Latest Revision: 3 March 2016

" Put in: ~/.vim/syntax/openstack.vim 
"  To use do:
"  :set filetype=openstack

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" OpenStack logfiles are: DATE TIME PID LOGLEVEL MODULE [REQUEST] TEXT

syn match   messagesBegin       display '^' nextgroup=messagesDate

syn match   messagesDate        contained display '\d\{4}-\d\d-\d\d *'
                                \ nextgroup=messagesHour skipwhite

syn match   messagesHour        contained display '\d\d:\d\d:\d\d\.\d\d\d\s*'
                                \ nextgroup=messagesPID

syn match   messagesPID         contained display '\d\+ '
                                \ nextgroup=messagesLevel

syn match   messagesLevel       contained display '\S*\s*'
                                \ nextgroup=messagesModule

syn match   messagesModule      contained display '\S*\s*'
                                \ nextgroup=messagesRequest

syn match   messagesRequest     contained display '\[.\{-}\]\s*'
                                \ nextgroup=messagesText contains=messagesReqUUID

syn match   messagesText        contained display '.*'
                                \ contains=messagesIP,messagesURL,messagesError,messagesUUID
"                                \ contains=messagesNumber,messagesIP,messagesURL,messagesError


syn match   messagesIP          '\d\+\.\d\+\.\d\+\.\d\+'

syn match   messagesReqUUID     'req-[0-9a-fA-F]\{8}-[0-9a-fA-F]\{4}-[0-9a-fA-F]\{4}-[0-9a-fA-F]\{4}-[0-9a-fA-F]\{12}'

syn match   messagesUUID        '[0-9a-fA-F]\{8}-[0-9a-fA-F]\{4}-[0-9a-fA-F]\{4}-[0-9a-fA-F]\{4}-[0-9a-fA-F]\{12}'

syn match   messagesURL         '\w\+://\S\+'

syn match   messagesNumber      contained '0x[0-9a-fA-F]*\|\[<[0-9a-f]\+>\]\|\<\d[0-9a-fA-F]*'

syn match   messagesError       contained '\c.*\<\(FATAL\|ERROR\|ERRORS\|FAILED\|FAILURE\|TRACEBACK\).*'


hi def link messagesDate        Constant
hi def link messagesError       ErrorMsg
hi def link messagesHour        Type
hi def link messagesIP          Constant
hi def link messagesRequest     Operator
hi def link messagesLevel       Type
hi def link messagesModule      Constant
hi def link messagesNumber      Number
hi def link messagesPID         Constant
hi def link messagesText        Normal
hi def link messagesURL         Underlined
hi def link messagesUUID        Identifier
hi def link messagesReqUUID     Type

let b:current_syntax = "openstack"

let &cpo = s:cpo_save
unlet s:cpo_save
