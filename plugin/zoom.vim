" plug/zoom.vim
" once {

if !NVPMTEST&&exists('ZOOMPLUGLOAD')|finish|else|let ZOOMPLUGLOAD=1|endif

" end-once}
" init {

let zoom = zoom#zoom()
call zoom.init()

" end-init}
" cmds {

command! Zoom call zoom.swap()

" end-cmds}
" acmd {

if get(g:,'zoom_autocmds',1)
  augroup ZOOM
    au!
    au WinEnter    * call zoom.back()
    au BufWinEnter * call zoom.help()
    au QuitPre     * call zoom.quit()
  augroup END
endif

" end-acmd}
