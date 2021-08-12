if exists('g:NVPM_ZOOM_PLUG_LOADED')|finish|endif

let g:NVPM_ZOOM_PLUG_LOADED = 1

let NVPMZoom = zoom#zoom()

call NVPMZoom.init()

command! NVPMZoomSwap call NVPMZoom.swap()

if get(g:,'NVPMZoom_autocommands',1)
  augroup NVPMZOOM
    au!
    au WinEnter    * call NVPMZoom.back()
    au BufWinEnter * call NVPMZoom.hman()
    au QuitPre     * call NVPMZoom.quit()
  augroup END
endif
