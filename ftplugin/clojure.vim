if exists('g:loaded_vim_iced_telescope_selector')
  finish
endif

if empty(globpath(&rtp, 'plugin/telescope.lua'))
  echoe 'plugin/telescope.lua is required.'
  finish
endif

if !exists('g:vim_iced_version')
     \ || g:vim_iced_version < 30801
  echoe 'iced-telescope-selector requires vim-iced v3.8.1 or later.'
  finish
endif

let g:loaded_vim_iced_telescope_selector = 1

if !exists('g:iced#selector#external')
  let g:iced#selector#external = {}
endif

let g:iced#selector#external['telescope'] = {
      \ 'runtimepath': 'plugin/telescope.lua',
      \ 'run': {config -> iced#telescope#selector#start(config)},
      \ }
