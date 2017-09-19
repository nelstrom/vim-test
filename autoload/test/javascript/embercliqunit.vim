if !exists('g:test#javascript#embercliqunit#file_pattern')
  let g:test#javascript#embercliqunit#file_pattern = '\v^tests/.*-test\.(js)$'
endif

" Returns true if the given file belongs to your test runner
function! test#javascript#embercliqunit#test_file(file)
  return a:file =~? g:test#javascript#embercliqunit#file_pattern
    \ && test#javascript#has_package('ember-cli-qunit')
endfunction

" Returns test runner's arguments which will run the current file and/or line
function! test#javascript#embercliqunit#build_position(type, position)
  let module = s:module_name(a:position)
  if !empty(module)
    let module = '--module='.module
  endif

  if a:type == 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '--filter='.name
    endif
    return [module, name]
  elseif a:type == 'file'
    return [module]
  else
    return []
  endif
endfunction

" Returns processed args (if you need to do any processing)
function! test#javascript#embercliqunit#build_args(args)
    return a:args
endfunction

" Returns the executable of your test runner
function! test#javascript#embercliqunit#executable()
  if filereadable('node_modules/.bin/ember')
    return 'node_modules/.bin/ember test'
  else
    return 'ember test'
  endif
endfunction

function! s:nearest_test(position)
  let name = test#base#nearest_test(a:position, g:test#javascript#patterns)
  return join(name['namespace'] + name['test'])
endfunction

function! s:module_name(position)
  for line in getbufline(a:position['file'], 1, 20)
    if match(line, '^moduleFor') >= 0
      let matches = matchlist(line, '\vmoduleFor\w*\(("[^"]+"|''[^'']+'')%(,\s*("[^"]+"|''[^'']+'')?)?')
      let [l:name, l:description] = matches[1:2]
      if !empty(l:description)
        return l:description
      else
        return l:name
      endif
    endif
  endfor
endfunction
