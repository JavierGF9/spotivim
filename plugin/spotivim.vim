if exists("g:spotivim_loaded")
	finish
endif

let g:spotivim_loaded = 1
let g:spotivim_map_keys = 0

function! spotivim#check_errors(output)
	if match(a:output, "Error org.freedesktop.DBus.Error.ServiceUnknown") != -1
		echom "ERROR: Spotify doesn't seem to be opened!"
	endif
endfunction

function! spotivim#toggle()
	let l:output = system("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
	call spotivim#check_errors(l:output)
endfunction

function! spotivim#pause()
	let l:output = system("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause")
	call spotivim#check_errors(l:output)
endfunction

function! spotivim#play()
	let l:output = system("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Play")
	call spotivim#check_errors(l:output)
endfunction

function! spotivim#stop()
	let l:output = system("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop")
	call spotivim#check_errors(l:output)
endfunction

function! spotivim#next()
	let l:output = system("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
	call spotivim#check_errors(l:output)
endfunction

function! spotivim#previous()
	let l:output = system("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
	call spotivim#check_errors(l:output)
endfunction

" Commands definitions
command! SpToggle call spotivim#toggle()
command! SpNext call spotivim#next()
command! SpPrevious call spotivim#previous()

" Mappings
if g:spotivim_map_keys
	nnoremap <F6> :SpToggle<CR>
endif
