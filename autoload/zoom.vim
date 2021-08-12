if exists('g:NVPM_ZOOM_AUTO_LOADED')|finish|endif

let g:NVPM_ZOOM_AUTO_LOADED = 1

" Private Methods
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


" Public Methods
fu! s:init() dict " {

  let self.enabled = 0

  let self.height = get(g: , 'NVPMZoom_height' , 20       )
  let self.width  = get(g: , 'NVPMZoom_width'  , 80       )
  let self.top    = get(g: , 'NVPMZoom_top'    , 2        )
  let self.left   = get(g: , 'NVPMZoom_left'   , 20       )
  let self.bottom = get(g: , 'NVPMZoom_bottom' , 2        )
  let self.right  = get(g: , 'NVPMZoom_right'  , 20       )
  let self.orient = get(g: , 'NVPMZoom_orient' , 'center' )
  let self.root   = '.nvpm/zoom'

  if type(self.height) != v:t_number || type(self.width) != v:t_number ||
    \type(self.top)    != v:t_number || type(self.left)  != v:t_number

    let self.height = 26
    let self.width  = 80
    let self.top    = 1
    let self.left   = 20

  endif

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

  let self.split = 0

endf " }
fu! s:calc() dict " {

  let currheight = winheight(0)
  let currwidth  = winwidth(0)

  "let self.height = (currheight <= self.height) ? currheight : self.height
  "let self.width  = (currwidth  <= self.width)  ? currwidth  : self.width

  if self.orient == 'center'
    let self.top    = floor((currheight-self.height)/2)
    let self.bottom = floor((currheight-self.height)/2)
    let self.left   = floor((currwidth-self.width)/2)
    let self.right  = floor((currwidth-self.width)/2)
  "else
    "let self.right  = currwidth  - (self.left + self.width)
    "let self.bottom = currheight - (self.top  + self.height)
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

endf " }
fu! s:show() dict " {

  call self.calc()

  let self.split = 1

  " Creating Splits
  if self.top > 0
    exec 'silent! top split '. self.tbuf
    let &l:statusline=' '
    "set nomodifiable
    "set readonly
    silent! wincmd p
  endif

  if self.bottom > 0
    exec 'silent! bot split '. self.bbuf
    let &l:statusline=' '
    "set nomodifiable
    "set readonly
    silent! wincmd p
  endif

  if self.left > 0
    exec 'silent! vsplit'. self.lbuf
    let &l:statusline=' '
    "set nomodifiable
    "set readonly
    silent! wincmd p
  endif

  if self.right > 0
    exec 'silent! rightbelow vsplit '. self.rbuf
    let &l:statusline=' '
    "set nomodifiable
    "set readonly
    silent! wincmd p
  endif

  "set modifiable
  "set noreadonly

  call self.size()

  let self.split = 0

  call self.save()
  call s:none()

  let self.enabled = 1

endf " }
fu! s:size() dict " {

  if self.left > 0
    silent! wincmd h
    exec 'vertical resize ' . string(self.left)
    silent! wincmd p
  endif

  if self.bottom > 0
    silent! wincmd j
    exec 'resize ' . string(self.bottom)
    silent! wincmd p
  endif

  exec 'resize          ' . string(self.height)
  exec 'vertical resize ' . string(self.width)

  if self.top > 0
    silent! wincmd k
    exec 'resize ' . string(self.top)
    silent! wincmd p
  endif

endfu "}

" -- au functions --
fu! s:hman() dict " {
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
endfu "}
fu! s:back() dict " {
  if (1+match(self.bufflist,bufname())) && !self.split
    let self.enabled = 0
    call self.bdel()
    call self.swap()
  endif
  if exists('g:nvpm.data.loaded') && !self.split
    if g:nvpm.data.loaded
      call g:nvpm.data.curr.edit()
    endif
  endif
endfu "}

" Interfacing
fu! zoom#zoom()   " {

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

  let self.hman = function("s:hman")
  let self.quit = function("s:quit")
  let self.back = function("s:back")

  return self

endf "}
