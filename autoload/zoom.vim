" auto/zoom.vim
" once {

if !NVPMTEST&&exists('ZOOMAUTOLOAD')|finish|else|let ZOOMAUTOLOAD=1|endif

" end-once}
" priv {

fu! s:none() " {

  hi TabLineFill  ctermfg=none ctermbg=none guifg=none guibg=bg
  hi TabLineSell  ctermfg=none ctermbg=none guifg=none guibg=bg
  hi StatusLine   ctermfg=none ctermbg=none guifg=none guibg=bg
  hi StatusLineNC ctermfg=none ctermbg=none guifg=bg   guibg=bg
  hi LineNr       ctermfg=none ctermbg=none guibg=bg
  hi SignColumn   ctermfg=none ctermbg=none guibg=bg
  hi VertSplit    ctermfg=none ctermbg=none guifg=bg guibg=bg
  hi NonText      ctermfg=none ctermbg=none guifg=bg

  "hi TagbarHighlight guibg='#4c4c4c' gui=none
  "hi Search guibg='#5c5c5c' guifg='#000000' gui=bold

endf " }
fu! s:buff() " {

  "set nomodifiable
  "set readonly
  "setlocal nobuflisted

endfu "}

" }
" publ {

fu! s:init() dict " {

  let self.enabled = 0

  let self.height  = get(g: , 'zoom_height' , 26 )
  let self.width   = get(g: , 'zoom_width'  , 80 )
  let self.left    = get(g: , 'zoom_left'   , 0  )
  let self.right   = get(g: , 'zoom_right'  , 0  )
  let self.layout  = get(g: , 'zoom_layout' , '' )

  let self.top     = 0
  let self.bot     = 0
  let self.root    = '.nvpm/zoom'

  let self.left  = self.left  < 0 ? 0 : self.left
  let self.right = self.right < 0 ? 0 : self.right
  "let self.top   = self.top   < 0 ? 0 : self.top
  "let self.bot   = self.bot   < 0 ? 0 : self.bot

  let self.tbuf = self.root.'/tbuf'
  let self.bbuf = self.root.'/bbuf'
  let self.rbuf = self.root.'/rbuf'
  let self.lbuf = self.root.'/lbuf'

  let self.groups = {}

  let self.hlgroups = [
  \'TabLine'      ,
  \'TabLineFill'  ,
  \'StatusLine'   ,
  \'StatusLineNC' ,
  \'LineNr'       ,
  \'SignColumn'   ,
  \'VertSplit'    ,
  \'NonText'      ,
  \]

  let self.bufflist = [self.lbuf,self.bbuf,self.tbuf,self.rbuf]

  call self.save()

  let self.spliting    = 0
  let self.laststatus  = &laststatus
  let self.showtabline = &showtabline
  let self.statusline  = &statusline

endf " }
fu! s:calc() dict " {

  let currheight = winheight(0)
  let currwidth  = winwidth(0)

  let self.top = self.top ? self.top : float2nr((currheight-self.height)/2)
  let self.bot = self.bot ? self.bot : float2nr((currheight-self.height)/2)

  if self.layout == 'left'
    let self.right = currwidth - self.width - self.left
  elseif self.layout == 'right'
    let self.left   = currwidth - self.width - self.right
  else
    let self.left  = float2nr((currwidth-self.width)/2)
    let self.right = float2nr((currwidth-self.width)/2)
  endif

endf " }
fu! s:bdel() dict " {
  execute ':silent! bdel '. self.lbuf
  execute ':silent! bdel '. self.bbuf
  execute ':silent! bdel '. self.tbuf
  execute ':silent! bdel '. self.rbuf
endf " }
fu! s:save() dict " {

  " TODO: pass this to another dictionary (make it private!)

  for group in self.hlgroups
    let output = execute('hi '.group)

    let self.groups[group] = {}

    let items  = []
    let items += ['cterm']
    let items += ['start']
    let items += ['stop']
    let items += ['ctermfg']
    let items += ['ctermbg']
    let items += ['gui']
    let items += ['guifg']
    let items += ['guibg']
    let items += ['guisp']
    let items += ['blend']

    for item in items
      let self.groups[group][item] = matchstr(output , item.'=\zs\S*')
    endfor

  endfor

endf " }
fu! s:hset() dict " {

  for group in self.hlgroups
    let fields = ''
    for item in keys(self.groups[group])
      if !empty(self.groups[group][item])
        let fields .= item.'='.self.groups[group][item].' '
      endif
    endfor
    execute 'highlight '.group.' '.fields
  endfor

endf " }
fu! s:swap() dict " {

  if self.enabled
    call self.hide()
  else
    call self.show()
  endif

endf " }
fu! s:hide() dict " {

  call self.bdel()
  let self.enabled = 0
  call self.hset()
  set cmdheight=1

  " FUTURE:
  " this will vanish or use new standard dict look up
  if exists('g:nvpm.data.loaded')
    if g:nvpm.data.loaded
      if !g:nvpm.line.visible|call g:nvpm.line.show()|endif
    else
      let &laststatus  = self.laststatus
      let &showtabline = self.showtabline
      let &statusline  = self.statusline
    endif
  else
    let &laststatus  = self.laststatus
    let &showtabline = self.showtabline
    let &statusline  = self.statusline
  endif

endf " }
fu! s:show() dict " {

  call self.calc()

  let self.spliting = 1

  call self.chop()
  call self.size()

  let self.spliting = 0

  call self.save()
  call s:none()

  " FUTURE:
  " this will vanish or use new standard dict look up
  let self.laststatus  = &laststatus
  let self.showtabline = &showtabline
  let self.statusline  = &statusline
  if exists('g:nvpm.data.loaded')
    if g:nvpm.data.loaded
      call g:nvpm.line.hide()
    else
      set laststatus=0
      set showtabline=0
      let &l:statusline=' '
    endif
  else
    set laststatus=0
    set showtabline=0
    let &l:statusline=' '
  endif

  let self.enabled = 1

endf " }
fu! s:chop() dict " {

  if self.left > 0
    exec 'silent! vsplit'. self.lbuf
    let &l:statusline=' '
    call s:buff()
    silent! wincmd p
  endif

  if self.right > 0
    exec 'silent! rightbelow vsplit '. self.rbuf
    let &l:statusline=' '
    call s:buff()
    silent! wincmd p
  endif

  if self.top > 0
    exec 'silent! top split '. self.tbuf
    let &l:statusline=' '
    call s:buff()
    silent! wincmd p
  endif

  "if self.bot > 0
    "exec 'silent! bot split '. self.bbuf
    "let &l:statusline=' '
    "call s:buff()
    "silent! wincmd p
  "endif


endf " }
fu! s:size() dict " {

  if self.left > 0
    silent! wincmd h
    exec 'vertical resize ' . self.left
    silent! wincmd p
  endif

  exec 'resize          ' . self.height
  exec 'vertical resize ' . self.width

  if self.top > 0
    silent! wincmd k
    exec 'resize ' . self.top
    silent! wincmd p
  endif

  if self.bot > 0
    exec 'set cmdheight='.self.bot
    "silent! wincmd j
    "exec 'resize ' . self.bot
    "silent! wincmd p
  endif

endfu "}

" -- au functions --
fu! s:help() dict " {
  let bufname=bufname()
  if &filetype == 'man'
    close
    let enabled = self.enabled
    if enabled
      call self.hide()
      exec 'edit '. bufname
      call self.show()
    else
      exec 'edit '. bufname
    endif
  endif
  if &filetype == 'help' && !self.enabled|only|endif
  if &filetype == 'help' && self.enabled &&!filereadable('./'.bufname)
    bdel
    exec 'edit '. bufname
  endif
endfu "}
fu! s:quit() dict " {
  call self.hide()
  quit
endfu "}
fu! s:back() dict " {
  if (1+match(self.bufflist,bufname())) && !self.spliting
    let self.enabled = 0
    call self.bdel()
    call self.swap()
  endif
  " FUTURE:
  " this will vanish or use new standard dict look up
  if exists('g:nvpm.data.loaded') && !self.spliting
    if g:nvpm.data.loaded
      call g:nvpm.data.curr.edit()
    endif
  endif
endfu "}

" }
" objc {

fu! zoom#zoom(...) " {

  let self = {}

  let self.init = function("s:init")
  let self.calc = function("s:calc")
  let self.bdel = function("s:bdel")
  let self.save = function("s:save")
  let self.hset = function("s:hset")
  let self.swap = function("s:swap")
  let self.hide = function("s:hide")
  let self.show = function("s:show")
  let self.size = function("s:size")
  let self.chop = function("s:chop")

  let self.help = function("s:help")
  let self.quit = function("s:quit")
  let self.back = function("s:back")

  return self

endf "}

" }
