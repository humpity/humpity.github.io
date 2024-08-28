% theme manager < HEW framework < public domain. by humpty.drivehq.com
% This file carries the default widget colors and theme routines
% v5.5
%---------------------------------------
fn.def theme_color (name$)	 	% set gr.color with color name$
	bundle.get 1, "theme", colors	% get the current theme
	bundle.get colors, name$, color$
					% activate the color
	split c$[],color$,"\\s*,\\s*"
	gr.color val(c$[1]),val(c$[2]),val(c$[3]),val(c$[4]),val(c$[5])
fn.end
%---------------------------------------
fn.def theme_recolor (name$,p)	 	% recolor paint with color name$
	bundle.get 1, "theme", colors	% get the current theme
	bundle.get colors, name$, color$

	split c$[],color$,"\\s*,\\s*"
	gr.color val(c$[1]),val(c$[2]),val(c$[3]),val(c$[4]),val(c$[5]),p
fn.end
%---------------------------------------
fn.def theme_swap (c1$,c2$)	 	% swap two colors
	bundle.get 1, "theme", colors	% get the current theme
	bundle.get colors, c1$, color1$
	bundle.get colors, c2$, color2$
	bundle.put colors, c1$, color2$
	bundle.put colors, c2$, color1$
fn.end
%---------------------------------------
fn.def theme_init ()			% init and load themes
	bundle.contain 1,"theme",rc
	if !rc then
	   bundle.create theme
	   bundle.put 1, "theme", theme  	% the global theme
	else
	   bundle.get 1, "theme", theme
	endif
	theme$="Default"		% default theme name
	bundle.put 1, "theme$", theme$ 	% set theme name

	bundle.put theme,"p_canvas", "255,255,255,255,1"
	bundle.put theme,"p_background", "255,255,255,255,1"
	bundle.put theme,"p_title", "255,140,10,10,1"
	bundle.put theme,"p_title_bg", "255,230,230,250,1"

	bundle.put theme,"p_text", "255,0,0,150,1"
	bundle.put theme,"p_text_bg", "255,255,255,255,1"

	bundle.put theme,"p_btn_border", "255,80,80,150,1"
	bundle.put theme,"p_btn_text", "255,30,30,30,1"
	bundle.put theme,"p_btn_backgnd","255,250,250,250,1"
	bundle.put theme,"p_btn_press_txt", "255,0,0,0,1"
	bundle.put theme,"p_btn_press_bg", "255,200,200,230,1"

	bundle.put theme,"p_np_border", "255,80,80,150,1"
	bundle.put theme,"p_np_text", "255,30,30,30,1"
	bundle.put theme,"p_np_backgnd", "255,250,250,250,1"
	bundle.put theme,"p_np_press_txt", "255,0,0,0,1"
	bundle.put theme,"p_np_press_bg", "255,200,200,230,1"

	bundle.put theme,"p_msg_border", "255,80,80,150,1"
	bundle.put theme,"p_msg_backgnd","255,240,240,255,1"
	bundle.put theme,"p_msg_text", "255,30,30,30,1"

	bundle.put theme,"p_ask_border", "255,80,80,150,1"
	bundle.put theme,"p_ask_backgnd","255,240,240,255,1"
	bundle.put theme,"p_ask_text", "255,30,30,30,1"

	bundle.put theme,"p_btm_backgnd", "255,220,220,220,1"
	bundle.put theme,"p_btm_grid", "255,100,100,100,0"
	bundle.put theme,"p_btm_text", "255,0,0,0,1"
	bundle.put theme,"p_btm_flash_bg","200,255,150,150,1"

	bundle.put theme,"p_prg_border","150,100,100,100,1"
	bundle.put theme,"p_prg_dots", "255,66,180,255,1"

	bundle.put theme,"p_tsc_border", "255,80,80,150,1"
	bundle.put theme,"p_tsc_backgnd","255,250,250,250,1"
	bundle.put theme,"p_tsc_text1", "255,30,30,30,1"
	bundle.put theme,"p_tsc_text2", "255,140,10,10,1"
	bundle.put theme,"p_tsc_text3", "255,10,140,10,1"

	bundle.put theme,"p_tbx_border", "255,80,80,150,0"
	bundle.put theme,"p_tbx_label", "255,80,80,150,1"
	bundle.put theme,"p_tbx_text", "255,30,30,30,1"
	bundle.put theme,"p_tbx_backgnd","255,255,255,255,1"

	bundle.put theme,"p_kin_border", "255,80,80,150,1"
	bundle.put theme,"p_kin_label", "255,220,220,240,1"
	bundle.put theme,"p_kin_text", "255,30,30,30,1"
	bundle.put theme,"p_kin_backgnd","255,250,250,250,1"

	bundle.put theme,"p_pf_backgnd", "255,240,240,240,1"
	bundle.put theme,"p_pf_border", "255,80,80,150,1"
	bundle.put theme,"p_pf_line", "255,80,80,150,0"
	bundle.put theme,"p_pf_label", "255,0,0,0,1"
	bundle.put theme,"p_pf_title_bg", "255,80,80,150,1"
	bundle.put theme,"p_pf_title_fg", "255,240,240,240,1"
	bundle.put theme,"p_pf_txinbg", "255,250,250,250,1"
	bundle.put theme,"p_pf_txinfg", "255,0,0,150,1"
	bundle.put theme,"p_pf_ckbor", "255,180,180,230,1"
	bundle.put theme,"p_pf_rdbor", "255,0,200,0,1"
	bundle.put theme,"p_pf_nb", "255,0,0,0,1"
	bundle.put theme,"p_pf_nf", "255,255,255,255,1"
	bundle.put theme,"p_pf_rdon", "255,0,0,0,1"
	bundle.put theme,"p_pf_ckon", "255,0,0,0,1"

	bundle.put theme,"p_pl_backgnd","255,240,240,240,1"
	bundle.put theme,"p_pl_border","255,80,80,150,1"
	bundle.put theme,"p_pl_line","255,80,80,150,0"
	bundle.put theme,"p_pl_label","255,0,0,0,1"
	bundle.put theme,"p_pl_title_bg","255,80,80,150,1"
	bundle.put theme,"p_pl_title_fg","255,240,240,240,1"

	bundle.put theme,"p_ch_title", "255,0,0,0,1"
	bundle.put theme,"p_ch_border", "255,200,200,230,1"
	bundle.put theme,"p_ch_line", "255,50,50,50,1"
	bundle.put theme,"p_ch_bar", "255,130,130,130,1"
	bundle.put theme,"p_ch_axis", "255,0,0,0,1"
	bundle.put theme,"p_ch_backgnd","255,255,255,255,1"

					% load last selected theme if any
	file.exists rc, "themes.ini"	% on sdcard ?
	if !rc then fn.rtn 0		% no
	text.open r,fv,"themes.ini"
!	if fv = -1 then fn.rtn			% can't open
	do					% find use_theme
	  text.readln fv,s$
	  if s$ = "EOF" |  is_in("[",s$) then d_u.break	 % fin
	  if ascii(s$)=35 | !is_in ("=",s$) then d_u.continue   % skip
	  n$ = word$ (s$,1,"\\s*=\\s*")  % name
	  v$ = word$ (s$,2,"\\s*=\\s*")  % value
	  if n$ <> "use_theme" then d_u.continue
	  theme$ = v$			% use this theme
	  d_u.break		 	% done
	until 0
	text.close fv

	call theme_load (theme$)	% load from theme.ini (if any)
fn.end %_theme_init
%---------------------------------------
fn.def theme_load (theme$)		% load theme from file

	file.exists rc, "themes.ini"	% on sdcard ?
	if !rc then fn.rtn 0		% no

	bundle.get 1,"theme", theme
	text.open r,fv,"themes.ini"
!	if fv = -1 then fn.rtn		% can't open
	do
	  text.readln fv,s$
	  if s$ = "EOF" then d_u.break
	  if ascii(s$)=35 then d_u.continue  	% comment
	  head = is_in ("[",s$)			% look for a theme
	  if !head then d_u.continue
	  tail = is_in ("]",s$)
	  if !tail then d_u.continue
	  if tail < head then d_u.continue
	  name$ = mid$ (s$, head+1, tail-head-1)
						% load theme
	  if name$ <> theme$ then d_u.continue 	% not this theme

	  bundle.put 1, "theme$", name$		% change name
	  do					% load colors
	    text.readln fv,s$
	    if s$ = "EOF" then d_u.break
	    if ascii(s$)=35 then d_u.continue 	% comment
	    if is_in("[",s$) then d_u.break  	% fin
	    if !is_in ("=",s$) then d_u.continue
	    n$ = word$ (s$,1,"\\s*=\\s*") 	% color name
	    v$ = word$ (s$,2,"\\s*=\\s*") 	% color str
	    bundle.put theme, n$,v$		% overwrite the color
	  until 0
	  d_u.break
	until 0
	text.close fv
fn.end %_theme_load
%---------------------------------------
fn.def theme_list (tlist)		% get list of themes from file
					% add nothing on fail
	file.exists rc, "themes.ini"	% on sdcard ?
	if !rc then fn.rtn	 	% no
	grabfile s$, "themes.ini"
	split lines$[],s$,"\\r*\\n" 	% split on eof, fix DOS leftovers.
	array.length last, lines$[]
	for i=1 to last
	      head = is_in ("[",lines$[i])	% look for a theme
	      if head then
		 tail = is_in ("]",lines$[i])
		 if !tail then f_n.continue
		 if tail < head then f_n.continue
		 name$ = mid$ (lines$[i], head+1, tail-head-1)
		 list.add tlist, name$
	      endif
	next
fn.end
%---------------------------------------
fn.def theme_set (theme$)	 	% set theme inside theme.ini
					% return 0=ok, 1=no theme, 2=no file
	bundle.put 1, "theme$", theme$

	file.exists rc, "themes.ini"	% on sdcard ?
	if !rc then fn.rtn 2		% no

	grabfile s$, "themes.ini"
	split lines$[],s$,"\\r*\\n" 	% split on eof, fix DOS leftovers.
	array.length last, lines$[]
	text.open w,fv,"themes.ini"
	for i=1 to last
	      if is_in ("use_theme", lines$[i]) then
		 lines$[i] ="use_theme = "+theme$ 	% set current theme
	      endif
	      text.writeln fv, lines$[i]	% update file
	next
	text.close fv
fn.rtn 0
fn.end %_theme_set
%---------------------------------------
