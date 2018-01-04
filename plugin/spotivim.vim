""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SpotiVim
"
" Author: Javier Gómez Fernández
" Version: 0.0.3 (not stable)
"
" Copyright 2017 Javier Gómez Fernández
"
" This script is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if (exists("s:spotivim_loaded") || system('uname') !~? 'Linux')
	" Until now the plug-in only works on Linux
	finish
endif

function s:CheckErrors(output)
	if match(a:output, "org.freedesktop.DBus.Error.ServiceUnknown") != -1
		echoerr "Spotify doesn't seem to be opened!"
		return 1
	else
		return 0
	endif
endfunction

function SP_Toggle()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")

	call s:CheckErrors(l:output)
endfunction

function SP_Pause()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause")

	call s:CheckErrors(l:output)
endfunction

function SP_Play()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ org.mpris.MediaPlayer2.Player.Play")

	call s:CheckErrors(l:output)
endfunction

function SP_Stop()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop")

	call s:CheckErrors(l:output)
endfunction

function SP_Next()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")

	call s:CheckErrors(l:output)
endfunction

function SP_Previous()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")

	call s:CheckErrors(l:output)
endfunction

function s:GetStatus()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get
	\ string:org.mpris.MediaPlayer2.Player
	\ string:PlaybackStatus")

	if !s:CheckErrors(l:output)
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

function s:GetMetadata()
	let l:output = system("dbus-send
	\ --print-reply
	\ --dest=org.mpris.MediaPlayer2.spotify
	\ /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get
	\ string:org.mpris.MediaPlayer2.Player
	\ string:Metadata | tail -n +2 | tr -d '\\n' | tr -s ' '")

	" Spotify doesn't send the track title when is very long, it also doesn't
	" send multiple artists nor album artists. Thus, arrays always have only one
	" item.

	if !s:CheckErrors(l:output)
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

function SP_GetArtistTitle()
	let l:metadata = s:GetMetadata()

	if !has_key(l:metadata, 'title')
		let l:metadata['title'] = 'Unknown'
	endif

	if !has_key(l:metadata, 'artist')
		let l:metadata['artist'] = 'Unknown'
	endif

	return l:metadata['title'] . ' - ' . l:metadata['artist']
endfunction

" Commands definitions
command -nargs=0 SpToggle call SP_Toggle()
command -nargs=0 SpNext call SP_Next()
command -nargs=0 SpPrevious call SP_Previous()
command -nargs=0 SpStatus echomsg SP_GetArtistTitle()

let s:spotivim_loaded = 1

" vim: noet:ts=2:sw=0
