""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SpotiVim
"
" Author: Javier Gómez Fernández
" Version: 0.0.1
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("g:spotivim_loaded")
	finish
endif
let g:spotivim_loaded = 1

function! spotivim#check_errors(output)
	if match(a:output, "org.freedesktop.DBus.Error.ServiceUnknown") != -1
		echom "ERROR: Spotify doesn't seem to be opened!"
		return 1
	else
		return 0
	endif
endfunction

function! spotivim#toggle()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")

	call spotivim#check_errors(l:output)
endfunction

function! spotivim#pause()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause")

	call spotivim#check_errors(l:output)
endfunction

function! spotivim#play()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ org.mpris.MediaPlayer2.Player.Play")

	call spotivim#check_errors(l:output)
endfunction

function! spotivim#stop()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop")

	call spotivim#check_errors(l:output)
endfunction

function! spotivim#next()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")

	call spotivim#check_errors(l:output)
endfunction

function! spotivim#previous()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")

	call spotivim#check_errors(l:output)
endfunction

function! spotivim#get_status()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get
	\ string:\"PlaybackStatus\"")

	if !spotivim#check_errors(l:output)
		let l:matched = matchstr(l:output, "Paused\\|Playing")

		if has("multi_byte")
			if l:matched ==? "Paused"
				return "[⏸]"
			elseif l:matched ==? "Playing"
				return "[▶️]"
			else
				return "[e]"
			endif
		else
			if l:matched ==? "Paused"
				return "[Pause]"
			elseif l:matched ==? "Playing"
				return "[Play]"
			else
				return "[e]"
			endif
		endif
	endif
endfunction

" Commands definitions
command! -nargs=0 SpToggle call spotivim#toggle()
command! -nargs=0 SpNext call spotivim#next()
command! -nargs=0 SpPrevious call spotivim#previous()
