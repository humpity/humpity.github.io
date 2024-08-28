% pickform.bas < HEW framework < public domain. by humpty.drivehq.com
% v3.1
%---------------------------------------
fn.def pickform_make (x,y,ww,wh, itmtyp,itmlab,itmval)

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "sbar",sbar
 gr.text.height theight			% use current font size
 theight=int(theight)
 x=int(x) : y=int(y) : ww=int(ww) : wh=int(wh)

 list.size itmtyp,nrows			% list size
 rh = theight * 2			% row height

 bundle.create wg			% save objects
 bundle.put wg, "x", x			% wanted
 bundle.put wg, "y", y
 bundle.put wg, "w", ww			% outer only
 bundle.put wg, "h", wh
 bundle.put wg, "theight", theight
 bundle.put wg, "itmtyp", itmtyp
 bundle.put wg, "itmlab", itmlab
 bundle.put wg, "itmval", itmval
 bundle.put wg, "subhist", ""		% subform history

 gosub pickform_update			% update real size & position
fn.rtn wg
fn.end %_pickform_make
%---------------------------------------
fn.def pickform (cmd$, data$, wg)

 gosub pickform_init			% load and execute
 if !rc then fn.rtn 0			% not input cmd

%--------------------			% get input and act on it
 menu_pressed = 0
 do
   if bk_pressed() then d_u.break       % if back key pressed
   row = 0
   do					% wait for touch
     if bk_pressed() then d_u.break     % if back key pressed

     gr.touch touched, x0, y0
     pause 50				% suppress cpu hack

     if background() & in_bg=0 then     % if app was put in bg
	in_bg=1			 % set flag
     else
	if !background() & in_bg=1 then      % if returned from bg
	   gr.render			% redraw graphics screen
	   in_bg=0			% re-toggle bg flag
	endif
     endif
   until touched
   let x0 = int(x0/scale_x)
   let y0 = int(y0/scale_y)
					% if outside, treat as quit
   if (x0<left)|(x0>right)|(y0<top)|(y0>bottom) then isr_set("_") % force bakkey
   if bk_pressed() then d_u.break       % if back key pressed

   yoff=0:yabs=0
   t0= time()
   do					% finger down
     gr.touch touched,x1,y1
     if !touched then d_u.break
     x1 = int(x1/scale_x)
     y1 = int(y1/scale_y)
     yoff = y1-y0			% +ve=pushed down -ve=pushed up
     yabs=abs(yoff)
     if yabs>rh/3 then gosub pickform_move  % core move routine
   until 0
   dt=time()-t0				% finger up
   if yabs<rh/3 then gosub pickform_get % hardly_moved=touch
   if yabs>rh & dt<300 then	 	% if swipe
      h = rh*yabs/yoff + yoff/3
      for i=1 to wrows*2
	  yoff+=h/i
	  gosub pickform_move
      next
   endif
   boff = offset			% accept move

 until menu_pressed
 if bk_pressed() then row=0		% if back key pressed, return 0
 isr_set("")				% reset backkey interrupt
 gosub pickform_exit
 fn.rtn row				% return row pressed
%---------------------------------------
pickform_move:	% core move. (un-snapped). enter with yoff.+ve=pushdown
					% yoff must be less than 2 buffers
 offset=boff+yoff

 if (offset) < (0-bheight+wh) then offset=0-bheight+wh % if pushed up to limit
 if (offset) > 0 then offset=0	  % if pushed down to limit
 gr.modify o_bmp, "y", top+bw+offset       % update bitmap position
 gr.render
return
%--------------------
pickform_blink:				% blink row
	call theme_swap ("p_pf_backg","p_pf_label")
	gosub pickform_printrow
	pause 125
	call theme_swap ("p_pf_backg","p_pf_label")
	gosub pickform_printrow
return
pickform_get:				% get touch
	x=x0-left-bw : if x<0 then x=0
	y=y0-top-bw  : if y<0 then y=0
	row = 1+floor((y-boff)/rh) 	% nth in list
	if row > nrows then return

	list.get itmtyp,row,t$
	t$=word$(t$,1,"\\|")		% strip embedded data

	if is_in (t$,"title,label") then return	% ignore these
	if is_in (t$,"menu,subform,picklist,integer,real,text_in") then gosub pickform_blink
	list.get itmtyp,row,t$

	if starts_with ("subform|",t$) then goto pickform_subform
	if t$<>"menu" then goto pickform_change

	pause 100			% delay before close
	menu_pressed=1
	return
pickform_subform:			% open subform
	t$=word$ (t$, 2,"\\|")		% extract widget# from type
	sub_wg = val(t$)

	bundle.get sub_wg, "left",l	% get subform
	bundle.get sub_wg, "right",r
	bundle.get sub_wg, "top",t
	bundle.get sub_wg, "bottom",b
	w=r-l+1 : h=b-t+1		% get size

	if data$="right" then		% moving left?
	   if left-w-bw*2 < 0 then		% no space to left?
	      x=right-bw
	   else
	      x=left-w+bw		% overlap borders
	   endif
	else				    % open right
	   if right+w+bw*2 > scr_w then	      % no space to right?
	      x=left-w+bw
	   else
	      x=right-bw		% overlap borders
	   endif
	endif
	if x=right-bw then tr$="left" else tr$="right"     % transition

	if x<0 then x=(scr_w-w)/2 : tr$="top"	% centre if x offscreen
	y = top+bw+boff+rh*(row-1)
	if y+h > scr_h then y= scr_h-h	% bottom if y offscreen

	pickform("setpos", int$(x)+","+int$(y), sub_wg)
	r = pickform("input",tr$, sub_wg)
	if r then
	   bundle.get sub_wg, "subhist",s$      % subform history
	   if r<0 then			% subform pressed?
	      bundle.put wg, "subhist", int$(row)+","+s$ % add me to chain
	   else
	      bundle.put wg, "subhist", int$(row)+","+int$(r) % last row
	   endif
	   row=-1			% flag subform presssed
	   menu_pressed =1
	else				% was cancelled
	   isr_set("pickform")		% clear bakkey, don't quit
	endif
	return
pickform_change:			% change dialog but don't quit
	list.get itmlab,row,s$
	list.get itmval,row,v$

	gr.text.size theight
	d$=word$(t$,2,"\\|")		% get embedded data
	t$=word$(t$,1,"\\|")		% strip it from type
 sw.begin t$
 sw.case "picklist"			% get text from picklist
	x=right-bw				% try to place it nearby
	y = top+bw+boff+rh*(row-1)
	r=picklist ("top|"+int$(x)+","+int$(y), d$)
	if r then
	v$ = word$(d$, r+1, ",") 	% word from list
	list.replace itmval,row,v$ 	% is new value
	else				% was cancelled
	isr_set("pickform")		% clear bakkey, don't quit
	endif
	gosub pickform_printrow
	sw.break
 sw.case "checkbox"
	if v$ = "0" then v$ = "1" else v$ = "0"
	list.replace itmval,row,v$
	gosub pickform_printrow
	sw.break
 sw.case "counter"			% counter
	v = val(v$)
	mx$=word$(d$,2,",")		% max
	mn$=word$(d$,1,",")		% min
	if mx$="" then mx=99 else mx=val(mx$)   % default max is 99
	if mn$="" then mn=0 else mn=val(mn$)    % default min is 0
	if mx>99 then mx=99 : if mx<0 then mx=0
	if mn>99 then mn=99 : if mn<0 then mn=0

	if (x<ci_left)&(x>co_left)&(v>mn) then v--	% dec -1
	if (x > ci_right) & (v<mx) then v++     % inc +1
	if (x < nb_left+theight) & (x>ci_left) & (v>mn+9) then v-=10 % dec -10
	if (x > nb_right-theight) & (x<ci_right) & (v<mx-9) then v+=10 % inc +10
	v$ = right$(format$("#%",v),2)
	if m$<>"" then v$=v$+"\|"+m$
	list.replace itmval,row,v$	% new value

	gosub pickform_printrow
	sw.break
 sw.case "radio"
	r=int(row)
	for row=1 to nrows		% look for all radios
	list.get itmtyp,row,t$
	if t$ = "radio" then
	   if (row=r) then v$ = "1" else v$ = "0"
	   list.replace itmval,row,v$
	   gosub pickform_printrow
	endif % radio
	next
	sw.break

 sw.case "integer"			% number
 sw.case "real"
	mx$=word$(d$,2,",")		% max
	mn$=word$(d$,1,",")		% min
	v=0				% default value=0
	if t$="integer" then
	r=numpad ("dotoff",&v)
	else
	r=numpad("default",&v)
	endif
	gr.text.size theight		% restore font

	if r then isr_set ("pickform")	% clear backkey, don't quit
!	if r then sw.break		% v1.90 bug
	if r then goto pickform_sw_end	% quit
	if t$="integer" then v$=int$(v) else v$=str$(v)
	err=0				% check max,min
	if mx$<>"" then err = v>val(mx$)
	if mn$<>"" then err+= v<val(mn$)
	if err then			% out of range
	x=right-scr_w/2		% place msg nearby
	y = top+bw+boff+rh*(row-0.5)-scr_h/2
	popup "Out of Range!",x,y, 0
	endif
	if !err then list.replace itmval,row,v$ % update new value
	gosub pickform_printrow
	sw.break
 sw.case "text_in"			 % text input
	input s$, v$,v$,cancelled	      % standard dialog
	if !cancelled then list.replace itmval,row,v$
	gosub pickform_printrow
	sw.break
pickform_sw_end:
 sw.end
return
%---------------------------------------
pickform_printrow:			% print row in bmp
	gr.bitmap.drawinto.start bmp
	gosub pickform_print		% print the line
	gr.bitmap.drawinto.end
	gr.render
return
%---------------------------------------
pickform_print:			       % print row in bmp

 list.get itmtyp,row,t$	% type   e.g checkbox|text
 list.get itmlab,row,s$	% label  e.g blue    |enter name:
 list.get itmval,row,v$	% value  e.g "1"     |john

 x = indent
 y = rh*row -1		% base line
 dy= y-rh*0.3		% solo text y pos
 dy1 = y-rh/2		% main text y pos
 dy2 = y-rh/8		% sub  text y pos

 gr.text.size theight		% recall font height
 gr.text.align 1

 t$=word$(t$,1,"\\|")		% strip embedded data
 if is_in (t$,"menu,title,subform") then % position labels
	f$=""
	fmt=is_in ("|",v$)		% if furthur subformat
	if fmt then
		f$ =mid$(v$,fmt+1)		% split val,subformat
		v$=mid$(v$,1,fmt-1)
	endif
	if v$="C"
		gr.text.align 2
		x = ww/2
	endif
	if v$="R"
		gr.text.align 3
		x = ww-indent
	endif
 endif %_menu, title, subform

 if ascii(s$)=126 then		% ignore line seperator ?
	s$=mid$(s$,2)
	sep=0
 else
	sep=1
 endif

 call theme_color ("p_pf_backg") 	% blank it out first
 gr.rect o,0,y-rh+1,ww,y+1

 if t$="title" then
	theme_color ("p_pf_title_bg")	% title bg
	if f$="B" then				% border (smaller fill)
		gr.rect o,bw,y-rh+bw+1,ww-bw,y-bw*2
		theme_color ("p_pf_border")
		gr.rect o, 0,y,ww,y-bw		% long line (fill paint)
		sep=0				% no seperator if border
	else
		gr.rect o,0,y-rh+1,ww,y+1	% no border. (fill)
	endif
 endif

 if sep & row<nrows then			% insert seperator ?
	gr.set.stroke bw/2			% min=0
	theme_color ("p_pf_line")
	gr.line o, indent,y,ww-indent,y	% seperation line
 endif

 gr.set.stroke 1
 if t$="title" then
	theme_color ("p_pf_title_fg")	% title fg
 else
	theme_color ("p_pf_label")	% label fg
 endif

 subtxt=is_in ("|",s$)		% if subtext embedded in label
 if subtxt then
	sb$ =mid$(s$,subtxt+1)		% split label,subtext
	s$=mid$(s$,1,subtxt-1)
	gr.text.draw o, x,dy1,s$	% print main label higher
	gr.text.size theight*0.75	% subtext size
	gr.text.draw o, x,dy2,sb$       % print subtext lower
	gr.text.size theight
 else				% solo label
	gr.text.draw o, x,dy,s$
 endif %_subtxt

 sw.begin t$
 sw.case "checkbox"
	call theme_color ("p_pf_ckbor")
	gr.rect o, ck_left,y-rh*5/6, ck_right,y-rh/6
	call theme_color ("p_pf_ckon")		  % tick on
	if v$ = "0" then theme_color ("p_pf_backg")   % tick off
	gr.rect o, tk_left,y-rh*5/6+ck_height/4,tk_right,y-rh/6-ck_height/4
	sw.break

 sw.case "counter"
	v = val(v$)
	call theme_color ("p_pf_ckbor") % p_count_of
	gr.rect o, co_left,y-rh*5/6, co_right,y-rh/6
	call theme_color ("p_pf_rdbor") % p_count_if
	gr.rect o, ci_left,y-rh*5/6, ci_right,y-rh/6
	call theme_color ("p_pf_nb")    % p_count_nb
	gr.rect o, nb_left,y-rh*5/6,nb_right,y-rh/6
	call theme_color ("p_pf_nf")    % p_count_nf
	gr.text.draw o,ci_left+0.3*theight, dy, "-"
	gr.text.draw o,ci_right-0.8*theight, dy, "+"
	v$ = right$(format$("#%",v),2)
	gr.text.draw o,nf_x, dy, v$     % number fg
	sw.break

 sw.case "radio"
	call theme_color ("p_pf_rdbor") % border
	gr.circle o, rd_x,y-rh/2,rd_radius
	call theme_color ("p_pf_rdon")  % on
	if v$="0" then call theme_color ("p_pf_backg")  % off
	gr.circle o, rd_x,y-rh/2,rd_radius/2
	sw.break

 sw.case "text_in"			% text input
 sw.case "picklist"			% or text using picklist widget
	while len(v$)			% shorten text
	gr.text.width w,v$
	if w < tx_right-tx_left-theight/6 then w_r.break else v$=left$(v$,-1)
	repeat
					% text input cropped
	call theme_color ("p_pf_txinbg")
	gr.rect o, tx_left, y-rh*5/6, tx_right, y-rh/6
	call theme_color ("p_pf_txinfg")
	gr.text.draw o, tx_left+theight/6, dy, v$
	sw.break
 sw.case "integer"			% number
 sw.case "real"
	gr.text.width s,s$		% label length
	s+=indent+theight
	gr.text.size theight*1.1	% numbers need to be bigger
	v= val(v$)
	if t$="integer" then f$="###############%" else f$="###############%.##"
	do
	f$=right$(f$,-1)		% decrease length
	v$=format$(f$,v)
	gr.text.width w,v$
	until tx_right-w > s | len(f$)<5	% until fits
	v$=replace$(v$," ","")	  % strip spaces
	gr.text.width w,v$
	ix=tx_right-w

	call theme_color ("p_pf_txinbg")
	gr.rect o, ix, y-rh*5/6, tx_right, y-rh/6
	call theme_color ("p_pf_txinfg")
	gr.text.draw o, ix, y-rh*1.5/6, v$
	gr.text.size theight
	sw.break
 sw.end
return %_pickform_print
%--------------------
pickform_init:				% load and execute command

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "scale_x",scale_x	% assume scaling
 bundle.get 1, "scale_y",scale_y	% otherwise these must be 1:1
 bundle.get 1, "sbar",sbar

 bundle.get wg, "left", left		% real
 bundle.get wg, "top", top
 bundle.get wg, "right", right
 bundle.get wg, "bottom", bottom
 bundle.get wg, "x", x			% wanted
 bundle.get wg, "y", y
 bundle.get wg, "w", ww			% outer only
 bundle.get wg, "h", wh
 bundle.get wg, "theight", theight
 bundle.get wg, "itmtyp", itmtyp
 bundle.get wg, "itmlab", itmlab
 bundle.get wg, "itmval", itmval

 list.size itmtyp,nrows			% actual list size
 rh = theight * 2			% row height

 if cmd$="input" then goto pickform_input
 rc=0					% flag not input cmd

 if cmd$="update" then goto pickform_update	% update widget metrics
 if cmd$="setfont" then
    theight=int(val(data$))
    bundle.put wg,"theight",theight
    gosub pickform_update
 endif
 if cmd$<>"setpos" then return

 x = int(val (word$ (data$, 1,",")))		% set new position
 y = int(val (word$ (data$, 2,",")))
 bundle.put wg, "x", x
 bundle.put wg, "y", y
!-------
pickform_update:			% update real size & position
					% ..with wanted (outer ww,wh)
 gr.text.size theight			% recall fontsize
 bw = int(theight/10)			% border width
 max1w = scr_w-bw*2			% for autowdith mode -1 (+gap)
 max1h = scr_h-sbar-bw*2		% for autoheight mode -1 (+gap)
 max2w = int(scr_w*0.66/rh)*rh		% for autowdith mode -2
 max2h = int((scr_h-sbar)*0.66/rh)*rh	% for autoheight mode -2
					% want auto sizing ?
 cy=0
 if wh<0 then				% auto height ?
    h=rh*nrows+bw*2			% outer
    if h>max1h then h=max1h		% autoheight mode -1 =full if too tall
    if wh<-1 & h>max2h then h=max2h	% autoheight mode -2 =limit if too tall
    if wh<-2 then cy=1			% autoheight (limit)+ y centering
    wh=h				% outer
 endif
 cx=0
 if ww<0 then				% autowidth mode -1 = max
    w=1
    for i=1 to nrows			% estimate label lengths
	list.get itmtyp,i,t$
	list.get itmlab,i,s$
	list.get itmval,i,v$
	t$=word$(t$,1,"\\|")		% strip subfmt/cmds
	b$=word$(s$,2,"\\|")		% split sub labels
	s$=word$(s$,1,"\\|")
	if ascii(s$)=126 then s$=mid$(s$,2)	% strip line supressors
	gr.text.width l,s$
	gr.text.size theight*2/3
	gr.text.width b,b$
	gr.text.size theight
	if b>l then l=b
	if is_in (t$,"text_in,picklist") then	% add estimated space
	   gr.text.width c,"H"
	   l=len(s$)
	   if l<len(v$) then l=len(v$)		% value is longer
	   l=c*(l*2+2)
	elseif t$="counter" then
	   l+=9*theight
	elseif t$="radio" | t$="checkbox" then
	   l+=3*theight
	elseif t$="integer" | t$="real" then
	   l+=6*theight
	else
	   l+=theight			% l/r padding for anything else
	endif
	if l>w then w=l
    next
    w+=bw*2				% outer
    if w>max1w then w=max1w		% force full if too wide
    if ww<-1 & w>max2w then w=max2w	% autowidth mode -2 = limit
    if ww<-2 then cx=1			% autowidth (limit)+ x centering
    ww=w				% outer
 endif %_auto modes

 if ww=0 | ww>=max1w then		% force full x ?
	ww=scr_w			% no gap
	x=0
 else
	if x=-1 then x = 0.5*(scr_w-ww)	% center x ?
	if x<-1 then x=-1*x-ww+1	% right justify ? (inclusive)
	if cx then x-=0.5*ww		% center justify ?
	if x<bw then x=bw		% force inside screen with gap
	if x+ww+bw > scr_w then x=scr_w-ww-bw
 endif

 if wh=0 | wh>=max1h then		% force full y ?
	wh=scr_h-sbar			% no gap
	y=sbar
 else
	if y=-1 then y = 0.5*(scr_h-wh)	% center y ?
	if y<-1 then y=-1*y-wh+1	% bottom justify ? (inclusive)
	if cy then y-=0.5*wh		% center justify ?
	if y<sbar+bw then y=sbar+bw	% force inside screen with gap
	if y+wh+bw > scr_h then y=scr_h-wh-bw
 endif
 x=int(x) : y=int(y)

 bundle.put wg, "left", x		% update real pos,size
 bundle.put wg, "top", y		% (all outer)
 bundle.put wg, "right", x+ww-1
 bundle.put wg, "bottom", y+wh-1
return %_pickform_init,setpos,update
!-------
pickform_input:

 gr.getdl dl_arr[],1			% save screen

 bw = int(theight/10)			% border width
 ww=right-left+1-bw*2			% use real sizes..
 wh=bottom-top+1-bw*2			% ..and inner wdw only
 wrows = int(wh/rh)			% max rows fills wdw
 boff = 0				% bmp y-offset from t
!-------
 indent = int(theight/4)		% left/right border
 tx_left = ww/2
 tx_right = ww-indent

 ck_height = rh*4/6	     % checkbox height
 ck_left   = ww-ck_height-indent	% checkbox left x pos
 ck_right  = ck_left + ck_height	% checkbox right x pos
 tk_height = ck_height/2		% tick (really a square)
 tk_left   = ck_left+ck_height/4
 tk_right  = tk_left+ck_height/2

 ct_height = rh*4/6	     % counter height
 co_left   = ww-8*theight-indent	% counter o-frame left
 co_right  = ww-indent		  % counter o-frame right

 ci_left   = co_left + 2*theight	% counter i-frame left
 ci_right  = ci_left + 4*theight	% counter i-frame right

 nb_left   = ci_left + 1*theight	% counter number bg left
 nb_right  = ci_left + 3*theight	% counter number bg right
 nf_x      = nb_left + 0.4*theight      % counter number fg x

 rd_radius = rh/3
 rd_x      = ww-rd_radius-indent
!-------				% create objects
 bheight = nrows*rh
 if bheight<wh then bheight=wh	  	% bmp must fill wdw
 theme_color ("p_pf_border")	  	% border
 gr.rect o_bord, left,top,right+1,bottom+1
 gr.bitmap.create bmp, ww, bheight	% create bitmap
 gr.clip o_clip, left+bw, top+bw, right-bw+1, bottom-bw+1, 0    % clip
 gr.bitmap.draw o_bmp, bmp, left+bw,top+bw
 gr.clip o_clip, 0, 0, scr_w, scr_h, 2	% release clip

 gr.bitmap.drawinto.start bmp
 call theme_color ("p_pf_backg")	% paint bg
 gr.rect o,0,0,ww,wh

 for row=1 to nrows			% fill form
     gosub pickform_print
 next
 gr.bitmap.drawinto.end
!-------				% execute input
 no_trans=0
 sw.begin data$
 sw.case "left"
	gr.modify o_bmp,"x",left-ww : dx=ww/8 : dy=0
	sw.break
 sw.case "right"
	gr.modify o_bmp, "x", right : dx= ww/-8 : dy=0
	sw.break
 sw.case "top"
	gr.modify o_bmp, "y", top-wh : dx=0 : dy=wh/8
	sw.break
 sw.case "bottom"
	gr.modify o_bmp, "y", bottom : dx=0 : dy=wh/-8
	sw.break
 sw.default
	no_trans=1		% no transition found
 sw.end
 if no_trans then goto pickform_open

 gr.hide o_bord
 gr.show o_bmp		% show transitions
 for i= 1 to 8
	gr.move o_bmp, dx,dy
	gr.render
 next
pickform_open:
 gr.modify o_bmp, "x", left+bw, "y", top+bw
 gr.show o_bmp
 gr.show o_bord
 gr.render
 rc=1			% flag is input cmd
return  %_pickform_init
%-----------------------
pickform_exit:				% exit the form
 no_trans=0
 sw.begin data$
 sw.case "left"
	dx=ww/-8 : dy=0
	sw.break
 sw.case "right"
	dx=ww/8 : dy=0
	sw.break
 sw.case "top"
	dx=0 : dy=wh/-8
	sw.break
 sw.case "bottom"
	dx=0 : dy=wh/8
	sw.break
 sw.default
	no_trans=1
 sw.end

 gr.hide o_bord
 if no_trans then goto pickform_close
 for i= 1 to 8
	gr.move o_bmp, dx,dy
	gr.render
 next
pickform_close:
 gr.hide o_bmp
 gr.bitmap.delete bmp			% release memory
 gr.newdl dl_arr[]			% restore display
 gr.render
return  %_pickform_exit
fn.end  % pickform
%---------------------------------------
