% button widget. < HEW framework < public domain. by humpty.drivehq.com
% v4.6
fn.def button_make (aux$, t$, style,x,y)	% constructor
				% depends on gr.text.size,typeface
				% style:0=link 1=rect 2=oval 3=rounded
				% 4=rounded2 5=bitmap
				% x,y is the top left corner

 if ascii(aux$)=124 then aux$="Z"+aux$  % do not allow empty+|
 fn$=word$(aux$,2,"\\|")	% split off filename
 aux$=word$(aux$,1,"\\|")

 if ascii(aux$)=126 then aux$="Z"+aux$  % do not allow empty+~
 wh$=word$(aux$,2,"~")	% split off size w,h
 aux$=word$(aux$,1,"~")

 gr.text.align 2		% center the text inside button
 gr.text.height th

 split.all t$[], t$,"\\|"	% get text lines into array
 array.length nlines,t$[]

 for blanks=0 to nlines-1
     if len(t$[blanks+1]) then f_n.break	% count leading empty lines
 next
 mw=0
 j=1
 for i= blanks+1 to nlines
     gr.text.width w2,t$[i] 	% get longest line
     if w2>mw then
	mw=w2
	j=i
     endif
 next i
 maxlen=len(t$[j])	      % max chars

 lpad = floor(th/10)		% border line thickness
 if style=2 then		% oval needs more padding
    xpad = th/2 + mw/20
    ypad = th/3 + mw/60   % th/2 + abs(maxlen-10)/5
 else
    xpad = th/2.5
    ypad = th/4
 endif
 if is_in ("N",aux$) then noborder=1 else noborder=0
 %~ if noborder then
    %~ ypad+=lpad
    %~ xpad+=lpad
 %~ endif

 bw = ceil(mw+2*xpad)
 bh = ceil(th*(nlines+0.1) + 2*ypad)

 if wh$<>"" then			% width height override
    if ascii(wh$)=44 then wh$="0"+wh$
    w$ = word$(wh$,1,",")
    h$ = word$(wh$,2,",")
    if w$<>"" then w=val(w$)
    if h$<>"" then h=val(h$)
    if w then bw=w
    if h then bh=h
    mw=bw-2*xpad
 endif

 l = floor(x)
 if is_in ("R",aux$) then l = floor(l-mw-2*xpad-1)	% right justify
 if is_in ("C",aux$) then l = floor(l-(mw+1)/2-xpad)	% centre
 t = floor(y)
 if is_in ("B",aux$) then t -= bh-1	% bottom
 r = l+bw-1
 b = t+bh-1
 list.create n, border			% border objects
 list.create n, press			% press objects

 call theme_color ("p_btn_border")      % outer border objects
 gr.paint.get p_border

 if noborder then goto button_skip      % no border

 if style=1 then			% rectangle
	gr.rect o,l,t,r,b
	list.add border, o
 endif
 if style=2 then			% oval
	gr.oval o,l,t,r,b
	list.add border, o
 endif
 if style=3 then			% rounded button
	rd =floor((b-t)/2)
	gr.circle o1, l+rd, t+rd, rd
	gr.circle o2, r-rd, t+rd, rd
	gr.rect o3, l+rd, t, r-rd, t+2*rd
	list.add border, o1,o2,o3
 endif
 if style=4 then		% rounded button2
	rd =lpad*4
	gr.circle o1, l+rd, t+rd, rd
	gr.circle o2, r-rd, t+rd, rd
	gr.circle o3, l+rd, b-rd, rd
	gr.circle o4, r-rd, b-rd, rd

	gr.rect o5, l+rd, t, r-rd, b
	gr.rect o6, l, t+rd, r, b-rd
	list.add border, o1,o2,o3,o4,o5,o6
 endif

button_skip:

 if style=5 then			% bitmap
	if fn$="" then fn$="button" 	% default if not provided
	off$=fn$+"_off.png"
	on$= fn$+"_on.png"
	gr.bitmap.load bmp,off$
	gr.bitmap.scale bmp_off, bmp, r-l,b-t
	gr.bitmap.delete bmp
	gr.bitmap.load bmp, on$
	gr.bitmap.scale bmp_on, bmp, r-l,b-t
	gr.bitmap.delete bmp

	gr.bitmap.draw o_bmp, bmp_off, l, t
	list.add border, o_bmp	  % treat o_bmp as a border object
 endif

 call theme_color ("p_btn_backgnd")	% background
 gr.paint.get p_backgnd

 if style=1 then
	gr.rect o,l+lpad,t+lpad,r-lpad,b-lpad
	list.add press, o
 endif
 if style=2 then
	gr.oval o,l+lpad,t+lpad,r-lpad,b-lpad
	list.add press, o
 endif
 if style=3 then
	rd =floor((b-t)/2)
	gr.circle o1, l+rd, t+rd, rd-lpad
	gr.circle o2, r-rd, t+rd, rd-lpad
	gr.rect o3, l+rd, ceil(t+lpad), r-rd, t+2*rd-lpad
	list.add press, o1,o2,o3
 endif
 if style=4 then
	rd =lpad*4
	gr.circle o1, l+rd, t+rd, rd-lpad
	gr.circle o2, r-rd, t+rd, rd-lpad
	gr.circle o3, l+rd, b-rd, rd-lpad
	gr.circle o4, r-rd, b-rd, rd-lpad

	gr.rect o5, l+rd, t+lpad, r-rd, b-lpad
	gr.rect o6, l+lpad, t+rd, r-lpad, b-rd
	list.add press, o1,o2,o3,o4,o5,o6
 endif

 call theme_color ("p_btn_press_bg")	% for pressed bg
 gr.paint.get p_press_bg

 gr.set.stroke 0			% draw text inside button
 call theme_color ("p_btn_press_txt")
 gr.text.underline !style		% pressed borderless text is underlined
 gr.paint.get p_press_txt
 gr.text.underline 0
 call theme_color ("p_btn_text")
 gr.paint.get p_text
 list.create n, tlist
 j=1
 for i= blanks+1 to nlines
     gr.text.draw o, l+xpad+mw/2, t+ypad+th*(j+blanks/2-0.1), t$[i]
     list.add tlist, o
     j++
 next i
					% create groups
 gr.group.list g_text,tlist
 gr.group.list g_press,press
 gr.group.list g_border,border
 list.create N, all
 list.add.list all, tlist
 list.add.list all, border
 list.add.list all, press
 gr.group.list g_all,all

 bundle.create wg			% create & return wg record
 bundle.put wg, "type", "button"	% record the object name and state
 bundle.put wg, "left", l
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "maxlen", maxlen
 bundle.put wg, "g_text", g_text
 bundle.put wg, "g_border", g_border
 bundle.put wg, "g_press", g_press
 bundle.put wg, "g_all", g_all
 bundle.put wg, "style", style
 bundle.put wg, "p_backgnd", p_backgnd
 bundle.put wg, "p_border",p_border
 bundle.put wg, "p_press_bg",p_press_bg
 bundle.put wg, "p_press_txt",p_press_txt
 bundle.put wg, "p_text",p_text
 bundle.put wg, "pressed", 0
 bundle.put wg, "bmp_off", bmp_off
 bundle.put wg, "bmp_on", bmp_on
 fn.rtn wg
fn.end
%---------------------------------------
fn.def button (cmd$, t$, wg)		% common button callback
					% t$=text inside button or "x,y"
	bundle.get wg, "g_text", g_text
	bundle.get wg, "g_border", g_border
	bundle.get wg, "g_press", g_press
	bundle.get wg, "g_all", g_all
	bundle.get wg, "style", style
	bundle.get wg, "p_backgnd", p_backgnd
	bundle.get wg, "p_border", p_border
	bundle.get wg, "p_press_bg", p_press_bg
	bundle.get wg, "p_press_txt",p_press_txt
	bundle.get wg, "p_text", p_text
	bundle.get wg, "pressed", pressed

	gr.get.value g_text,"list",tlist
	gr.get.value g_press,"list",press

	sw.begin cmd$
	sw.case  "flash"			% press momentarily
		if !pressed then gosub button_flash % cannot flash if pressed
		sw.break
	sw.case "text"				% change text
		gosub button_text
		sw.break
	sw.case "show"				% show & enable
		call event_insert (wg)
		gr.show g_all
		sw.break
	sw.case "hide"				% hide & disable
		call event_remove (wg)
		gr.hide g_all
		sw.break
	sw.case "move"			% move to t$="x,y" or "+-x,+-y"
		gosub button_move
		sw.break
	sw.case "set"			% set press value
		gosub button_set
		sw.break
	sw.end
fn.rtn 0
%---------------------
button_move:
	bundle.get wg,"left", left
	bundle.get wg,"top", top
	bundle.get wg,"right", right
	bundle.get wg,"bottom", bottom
	x$ =word$ (t$, 1,",")
	y$ =word$ (t$, 2,",")
	x = val(x$)
	y = val(y$)
				% check if relative or absolute
	if ascii(x$) < 48 then xoff = x else xoff = x-left
	if ascii(y$) < 48 then yoff = y else yoff = y-top

	gr.move g_all,xoff,yoff

	bundle.put wg, "left", left+xoff
	bundle.put wg, "top", top+yoff
	bundle.put wg, "right", right+xoff
	bundle.put wg, "bottom", bottom+yoff
return
%---------------------
button_text:				% change text
	bundle.get wg, "maxlen",maxlen
	list.size tlist, tsize
	split.all t$[], t$,"\\|"
	array.length nlines,t$[]
					% note: box size is unchangable
	for i= 1 to tsize
	    if i> nlines then t$="" else t$=t$[i]
	    if len(t$)>maxlen then t$=left$(t$,maxlen) % truncate
	    list.get tlist,i,o
	    gr.modify o, "text", t$	% replace text
	next
return
%---------------------
button_flash:				% press the button t$ times
	if t$<>"" then n=val(t$) else n=1

	for f = 1 to n
	    gosub button_press
	   do				% wait until finger lifted
	     gr.touch touched,x,y
	   until !touched
	   pause 100
	   gosub button_release
	   if n>1 then pause 100
	next f
return
%---------------------
button_set:
	if pressed then
	   do				% wait until finger lifted
	     gr.touch touched,x,y
	   until !touched
	endif
	pressed = val(t$)
	bundle.put wg, "pressed", pressed
	if pressed then gosub button_press else gosub button_release
	do				% wait until finger lifted
	  gr.touch touched,x,y
	until !touched
return
%---------------------
button_press:				% press objects
	gr.modify g_press,"paint", p_press_bg
	gr.modify g_text,"paint", p_press_txt

	if style=5 then			% change bitmap
	   gr.get.value g_border,"list",border
	   list.get border,1,o_bmp
	   bundle.get wg, "bmp_on",bmp_on
	   gr.modify o_bmp, "bitmap", bmp_on
	endif
	gr.render
return
%---------------------
button_release:
	gr.modify g_press,"paint", p_backgnd
	gr.modify g_text,"paint", p_text

	if style=5 then		 % change bitmap
	   gr.get.value g_border,"list",border
	   list.get border,1,o_bmp
	   bundle.get wg, "bmp_off",bmp_off
	   gr.modify o_bmp, "bitmap", bmp_off
	endif
	gr.render
return
%---------------------
fn.end
%---------------------------------------
