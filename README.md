# Introduction

  Zoom  features a highly important functionality, for any decent text editor,
  known as Distraction Free, Noise-Free or maybe even No-Distraction-Mode. The
  feature  consists  on  making  everything  hidden but the text being edited.
  Also, the very window that holds the text is  put in evidence, mainly in the
  middle of the screen. This plug-in is able to do  all  that  and  more.  The
  feature  can  mostly  be appreciated by programmers, novelists, journalists,
  paper writers, and others.  Because  when the idea comes, you don't wanna be
  distracted  with  tablines, filenames or  anything  else  for  that  matter.

  It's  also important to mention that Zoom is 100% compatible with all NVPM's
  plug-ins  the  user  can  find  in the group's main repository. See the NVPM
  groups section below.

  And here is a quick demonstration for this plugin:

  <figure>
  <p align=center>
    <img width=85% height=85%
    src="https://github.com/nvpm/home/raw/main/zoom.gif"/>
  </p>
  </figure>

# Installation

## Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'https://gitlab.com/nvpm/zoom' , {'branch' : 'main'}
```

## Using runtimepath

```bash
cd $HOME
git clone https://gitlab.com/nvpm/zoom
echo "set runtimepath+=~/zoom" >> .config/nvim/init.vim
```
## Copying files with bash

```bash
cd $HOME
git clone https://gitlab.com/nvpm/zoom
cp -r zoom/{plugin,autoload,version,LICENSE} .config/nvim
mkdir -p .config/nvim/doc
cp zoom/doc/zoom.txt .config/nvim/doc
nvim +'helptags .config/nvim/doc' +'qall'
```
# Configuration

```vim
let zoom_height = 26
let zoom_width  = 80
let zoom_layout = ''
let zoom_left   = 0
let zoom_right  = 0

nmap <silent>mn    :Zoom<cr>
nmap <silent><F11> :Zoom<cr>
```

# Usage `:Zoom`

For more info, see `:help zoom`

# Discussions and news on Telegram (in Portuguese and English)

* [group](https://t.me/nvpmuser)
* [channel](https://t.me/nvpmnews)
