let s:save_cpo = &cpoptions
set cpoptions&vim

let s:registry = {}

lua <<EOT
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values

  function VimIcedTelescopeSelector(temp_fn_id, items, opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = "vim-iced",
      finder = finders.new_table {
        results = items
      },
      sorter = conf.generic_sorter(opts),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.fn['iced#telescope#selector#call_temp_fn'](temp_fn_id, selection[1])
        end)
        return true
      end,
    }):find()
  end
EOT

function! s:register_temp_fn(callback) abort
  let id = sha256(string(a:callback))
  let s:registry[id] = a:callback
  return id
endfunction

function! s:unregister_temp_fn(id) abort
  if !has_key(s:registry, a:id)
    return
  endif
  silent unlet s:registry[a:id]
endfunction

function! iced#telescope#selector#call_temp_fn(id, ...) abort
  if !has_key(s:registry, a:id)
    return
  endif
  let ret = call(s:registry[a:id], a:000)
  call s:unregister_temp_fn(a:id)
  return ret
endfunction

function! iced#telescope#selector#start(config) abort
  let candidates = get(a:config, 'candidates', [])
  let Callback = get(a:config, 'accept', '')
  if type(Callback) != v:t_func
    return
  endif

  let id = s:register_temp_fn({s -> Callback('', s)})
  call luaeval('VimIcedTelescopeSelector(_A[1], _A[2])', [id, candidates])
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
