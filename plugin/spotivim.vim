""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SpotiVim
"
" Author: Javier Gómez Fernández
" License: GNU General Public License version 3
" Version: 0.0.2 (not stable)
"
" TODO: Add documentation
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if (exists("g:spotivim_loaded") || system('uname') !~? 'Linux')
	finish
endif
let g:spotivim_loaded = 1

function! spotivim#check_errors(output)
	if match(a:output, "org.freedesktop.DBus.Error.ServiceUnknown") != -1
		echoerr "Spotify doesn't seem to be opened!"
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
	\ string:org.mpris.MediaPlayer2.Player
	\ string:PlaybackStatus")

	if !spotivim#check_errors(l:output)
		let l:matched = matchstr(l:output, "Paused\\|Playing")

		if has("multi_byte")
			if l:matched ==? "Paused"
				return "[||]"
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

function! spotivim#get_metadata()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get
	\ string:org.mpris.MediaPlayer2.Player
	\ string:Metadata | tail -n +2 | tr -d '\\n' | tr -s ' '")

	" Spotify doesn't send the track title when is very long, it also doesn't
	" send multiple artists nor album artists. Thus, arrays always have only one
	" item.

	if !spotivim#check_errors(l:output)
		let l:metadata = {}
		let l:index = 0

		while (match(l:output, 'dict entry([^(]*)', l:index) != -1)
			let l:entry = matchlist(l:output, 'dict entry( string "\([a-zA-Z:]*\)" variant \(\w*\) \([^(]*\) )', l:index)

			" FIXME: if track or artist has parentheses they won't match.

			if (l:entry[1] ==# 'mpris:trackid' && l:entry[2] ==# 'string')
				let l:metadata['id'] = strcharpart(l:entry[3], 1, strlen(l:entry[3]) - 2)  " Clean the string
			elseif (l:entry[1] ==# 'mpris:length' && l:entry[2] =~# '\m.\?int.\?.\?')
				let l:metadata['length'] = str2nr(l:entry[3])
			elseif (l:entry[1] ==# 'mpris:artUrl' && l:entry[2] ==# 'string')
				let l:metadata['artistUrl'] = strcharpart(l:entry[3], 1, strlen(l:entry[3]) - 2)
			elseif (l:entry[1] ==# 'xesam:album' && l:entry[2] ==# 'string')
				let l:metadata['album'] = strcharpart(l:entry[3], 1, strlen(l:entry[3]) - 2)
			elseif (l:entry[1] ==# 'xesam:albumArtist' && l:entry[2] ==# 'array')
				let l:metadata['albumArtist'] = matchlist(l:entry[3], 'string "\(\p*\)"')[1] " Broken D-Bus message?
			elseif (l:entry[1] ==# 'xesam:artist' && l:entry[2] ==# 'array')
				let l:metadata['artist'] = matchlist(l:entry[3], 'string "\(\p*\)"')[1] " Broken D-Bus message?
			elseif (l:entry[1] ==# 'xesam:autoRating' && l:entry[2] ==# 'double')
				let l:metadata['rating'] = str2float(l:entry[3])
			elseif (l:entry[1] ==# 'xesam:discNumber' && l:entry[2] =~# '\m.\?int.\?.\?')
				let l:metadata['disc'] = str2nr(l:entry[3])
			elseif (l:entry[1] ==# 'xesam:title' && l:entry[2] ==# 'string')
				let l:metadata['title'] = strcharpart(l:entry[3], 1, strlen(l:entry[3]) - 2)
			elseif (l:entry[1] ==# 'xesam:trackNumber' && l:entry[2] =~# '\m.\?int.\?.\?')
				let l:metadata['track'] = str2nr(l:entry[3])
			elseif (l:entry[1] ==# 'xesam:url' && l:entry[2] ==# 'string')
				let l:metadata['url'] = strcharpart(l:entry[3], 1, strlen(l:entry[3]) - 2)
			endif

			let l:index = matchend(l:output, 'dict entry([^(]*)', l:index)
		endwhile

		return l:metadata
	endif
endfunction

function! spotivim#get_title_artist()
	let l:metadata = spotivim#get_metadata()

	return l:metadata['title'] . ' - ' . l:metadata['artist']
endfunction

" Commands definitions
command! -nargs=0 SpToggle call spotivim#toggle()
command! -nargs=0 SpNext call spotivim#next()
command! -nargs=0 SpPrevious call spotivim#previous()
command! -nargs=0 SpStatus echom spotivim#get_title_artist()
