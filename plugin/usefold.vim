function! s:foldmarkerstuff() "{{{
	let fmarks = split(&foldmarker, ',')
	let fbeg = printf(&commentstring, fmarks[0])
	let fend = printf(&commentstring, fmarks[1])
	let fbegx = escape(fbeg, '\')
	let fendx = escape(fend, '\')
	return [fbeg, fend, fbegx, fendx]
endfunction "}}}

function! Usefold_FoldDown(...) "{{{
	let fblno = line('.')
	if a:0 == 1
		let fblno = a:1
	endif
	let fms = s:foldmarkerstuff()
	let il = indent(fblno)
	if match(getline(fblno), '\S') == -1
		echoerr "No folding empty lines"
		return
	endif
	let felno = fblno + 1
	let lnosav = felno
	while (indent(felno) > il || match(getline(felno), '\S') == -1) && indent(felno) != -1
		if match(getline(felno), '\S') != -1
			let lnosav = felno
		endif
		let felno = felno + 1
	endwhile
	echo lnosav
	if &filetype == "python"
		let felno = lnosav
		call setline(fblno, substitute(getline(fblno), '$', ' '.fms[0], ''))
		call append(felno, repeat(' ', il) . fms[1])
	else
		if match(getline(felno), '\S') == -1
			let felno = lnosav
		end
		call setline(fblno, substitute(getline(fblno), '$', ' '.fms[0], ''))
		call setline(felno, substitute(getline(felno), '$', ' '.fms[1], ''))
	endif
endfunction "}}}

function! Usefold_FoldUp(...) "{{{
	let l = line('.')
	if a:0 == 1
		let l = a:1
	endif
	while match(getline(l), '\S') == -1 && l > 0
		let l = l - 1
	endwhile
	let il = indent(l)
	let l = l-1
	while l > 0 && (indent(l) > il || match(getline(l), '\S') == -1)
		let l = l - 1
	endwhile
	if indent(l) > -1
		call Usefold_FoldDown(l)
	endif
endfunction "}}}

function! Usefold_FromInside(...) "{{{
	let l = line('.')
	if a:0 == 1
		let l = a:1
	endif
	while match(getline(l), '\S') == -1 && l > 0
		let l = l - 1
	endwhile
	let il = indent(l)
	if il == 0
		return
	endif
	while l > 0 && (indent(l) >= il || match(getline(l), '\S') == -1)
		let l = l - 1
	endwhile
	if indent(l) > -1
		call Usefold_FoldDown(l)
	endif
endfunction "}}}

function! Usefold_foldtext() "{{{
	let fms = s:foldmarkerstuff()
	let fbline = substitute(getline(v:foldstart), '\v^\s*(.{-})\s*\V'.fms[2].'\v.*$' , '\1', '')
	let feline = substitute(getline(v:foldend), '\v^\s*(.{-})\s*\V'.fms[3].'\v.*$' , '\1', '')
	let linec = v:foldend - v:foldstart - 1
	let linecs = 'lines'
	if linec == 1
		let linecs = 'line'
	endif
	return repeat(" ", indent(v:foldstart)) . fbline . ' ... (' . linec . ' ' . linecs . ') ... ' . feline
endfunction "}}}
