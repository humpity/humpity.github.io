% text scroll widget. < HEW framework < public domain. by humpty.drivehq.com
% v5.2

fn.def txtscroll_make (aux$, tlist, x,y,ww,wh)   % constructor

					% depends on gr.text.size,typeface
	bundle.get 1, "scr_w", scr_w
	bundle.get 1, "scr_h", scr_h

 x=int(x) : y=int(y) : ww=int(ww) : wh=int(wh)
 list.size tlist,nlines
 gr.text.height theight
 theight=int(theight)
 row_height = int(theight *5/4)	% have row_height be a bit taller than text
 gr.set.stroke 0

 pad = ceil(row_height/4)		% border to text
 bw= int (theight/10)			% border width

 if x+ww > scr_w then ww=scr_w-x	% make sure wdw fits inside screen
 if y+wh > scr_h then wh=scr_h-y
 nrows = int ((wh-pad*2)/row_height)	% max rows that fit
 if nrows=0 then nrows=1		% zero rows not allowed
					% change ww,wh to be inner window
 wh = nrows * row_height		% make height exact
 ww = ww-pad*2

 l = x					% outer wdw
 t = y
 r = l+pad*2+ww-1
 b = t+pad*2+wh-1

 x2= r					% inclusive right
 y2= b					% inclusive bottom
 rd=pad
 list.create N,all

 raw=is_in ("W",aux$) 			% raw mode ?
 snap=is_in ("S",aux$) 			% snap mode ?

 call theme_color ("p_tsc_border") 	% border
 if is_in ("R",aux$) then		% rounded border ?
    gr.rect b1, x,y+rd,x2+1,y2-rd+1
    gr.rect b2, x+rd,y,x2-rd+1,y2+1
    gr.circle b3, x+rd,y+rd,rd
    gr.circle b4, x2-rd,y+rd,rd
    gr.circle b5, x+rd,y2-rd,rd
    gr.circle b6, x2-rd,y2-rd,rd
    gr.group o_bord,b1,b2,b3,b4,b5,b6
    list.add all, b1,b2,b3,b4,b5,b6
 else
    gr.rect o_bord, x,y,x2+1,y2+1		% square border
    list.add all, o_bord
 endif
 if is_in ("N",aux$) then gr.modify o_bord,"alpha",0    % border not wanted

 call theme_color ("p_tsc_backg")     % background
 if is_in ("R",aux$) then	       % rounded border ?
    rd-=bw
    x+=bw : y+=bw : x2-=bw : y2-=bw
    gr.rect p1, x,y+rd,x2+1,y2-rd+1
    gr.rect p2, x+rd,y,x2-rd+1,y2+1
    gr.circle p3, x+rd,y+rd,rd
    gr.circle p4, x2-rd,y+rd,rd
    gr.circle p5, x+rd,y2-rd,rd
    gr.circle p6, x2-rd,y2-rd,rd
    list.add all, p1,p2,p3,p4,p5,p6
 else
    gr.rect o_back, x+bw,y+bw,x2-bw+1,y2-bw+1
    list.add all, o_back
 endif
!-------
 gr.bitmap.create bmp1, ww, wh		% bmp1 (empty)
 gr.bitmap.drawinto.start bmp1
 gosub txtscroll_bg			% paint bg
 gr.bitmap.drawinto.end
!-------
 gr.bitmap.create bmp2, ww, wh		% fill bmp2
 gr.bitmap.drawinto.start bmp2
 gosub txtscroll_bg			% paint bg

 row =1
 for n=1 to nrows
     if row>nlines then f_n.break
     gosub txtscroll_print
     row++
 next
 gr.bitmap.drawinto.end
!-------
 gr.bitmap.create bmp3, ww, wh		% fill bmp3
 gr.bitmap.drawinto.start bmp3
 gosub txtscroll_bg			% paint bg
 for n=1 to nrows
     if row>nlines then f_n.break
     gosub txtscroll_print
     row++
 next
 gr.bitmap.drawinto.end
!-------				% initial bmp positions
 gr.clip o_clip1, l+pad, t+pad, r-pad+1, b-pad+1, 0		% clip wdw
 gr.bitmap.draw o_bmp1, bmp1, l+pad,t+pad-wh
 gr.bitmap.draw o_bmp2, bmp2, l+pad,t+pad
 gr.bitmap.draw o_bmp3, bmp3, l+pad,t+pad+wh
 gr.clip o_clip2, 0, 0, scr_w, scr_h, 2	% release clip
!-------
 list.add all, o_clip1
 list.add all, o_bmp1
 list.add all, o_bmp2
 list.add all, o_bmp3
 list.add all, o_clip2
 gr.group.list g_all, all
!-------
 topw = 1				% top line of wdw
 boff = 0				% bmp2 y-offset from t
 nxtrow = 2*nrows+1			% next row unbuffered
 prvrow = 0-nrows			% previous row unbuffered
!-------
 bundle.create wg			% create & return wg record
 bundle.put wg, "type", "txtscroll"
 bundle.put wg, "left", l		% outer wdw
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "o_bmp1", o_bmp1
 bundle.put wg, "o_bmp2", o_bmp2
 bundle.put wg, "o_bmp3", o_bmp3
 bundle.put wg, "g_all", g_all

 bundle.put wg, "nrows", nrows		% # lines in window
 bundle.put wg, "topw", topw		% top line in window
 bundle.put wg, "boff", boff		% bmp2 y offset from t
 bundle.put wg, "nxtrow", nxtrow	% row after buffers
 bundle.put wg, "prvrow", prvrow	% row before buffers
 bundle.put wg, "ww", ww		% inner window width
 bundle.put wg, "wh", wh		% inner window height
 bundle.put wg, "raw", raw		% raw text mode on/off
 bundle.put wg, "snap", snap		% snap mode on/off
 bundle.put wg, "theight", theight
 bundle.put wg, "tlist", tlist

 fn.rtn wg
fn.end
%---------------------------------------
fn.def txtscroll (cmd$, num, wg)	% callback
					% return (cmd dependant)
	bundle.get wg, "left", l
	bundle.get wg, "top",  t	% outer
	bundle.get wg, "right", r
	bundle.get wg, "bottom", b
	bundle.get wg, "o_bmp1", o_bmp1
	bundle.get wg, "o_bmp2", o_bmp2
	bundle.get wg, "o_bmp3", o_bmp3
	bundle.get wg, "g_all", g_all
	bundle.get wg, "nrows", nrows
	bundle.get wg, "topw", topw
	bundle.get wg, "boff", boff
	bundle.get wg, "nxtrow", nxtrow
	bundle.get wg, "prvrow", prvrow
	bundle.get wg, "ww", ww
	bundle.get wg, "wh", wh
	bundle.get wg, "raw", raw
	bundle.get wg, "snap", snap
	bundle.get wg, "theight", theight
	bundle.get wg, "tlist", tlist

	bundle.get 1, "scale_x",scale_x % get global vars (hack)
	bundle.get 1, "scale_y",scale_y

	gr.set.stroke 0
	gr.text.size theight		% recall font size
	row_height = int(theight *5/4)
	t+=ceil(row_height/4)		% t is now inner top

	list.size tlist,nlines

	oldtopw = topw
	rc=0				% default return code

!-------				% line scroll mode ?
	sw.begin cmd$
	sw.case "touch"			% touch mode scroll
		bundle.get wg, "x",x0   % passed touch point
		bundle.get wg, "y",y0
		holdboff = boff
		holdtopw = topw
		tapped=1		% assume tapped

		gosub txtscroll_touch   % do finger scroll
		if snap then gosub txtscroll_snap
		if int(topw) <> int(holdtopw) then tapped=0

		if tapped then		% if just a touch
		   rc=int(topw + (y0-t)/row_height)	% tapped row
		   if rc > nlines then rc=-1	% tapped out of range
		else
		   rc=0			% not a tap, is a scroll
		endif
		sw.break
	sw.case "scroll"		% scroll num lines mode or fling
		holdboff = boff
		holdtopw = topw
		sheight = row_height * num	     % +ve=pushdown
		jump = num/abs(num)*row_height
		for yoff = 0 to sheight step jump/2
		    gosub txtscroll_move
		next
		if snap then gosub txtscroll_snap
		rc=topw			% return the top row
		sw.break
	sw.case "goto"		  	% goto row number, snap & refresh
		if topw > nlines then topw=1	% illegal topw, reset it
		row = int(num)
		if row>nlines then row=nlines	% try to force legal if over
		if row=0 then row=topw		% 0 means just refresh current page
		if row<0 then row=1		% force legal if under
					% note: nlines can be zero to do nothing (blank list)
		gosub txtscroll_goto
		sw.break
	sw.case "roll"			% roll on line num
		gosub txtscroll_roll
		sw.break
	sw.case "hide"			% hide
		gosub txtscroll_hide
		sw.break
	sw.case "show"			% show
		gosub txtscroll_show
		sw.break
	sw.case "printrow"		% re-print row in wdw
		gosub txtscroll_printrow
		sw.break
	sw.case "gettop"		% get the top row# in wdw
		rc=topw
		sw.break
	sw.case "getbot"		% get the bottom row# inside wdw
		rc=topw+nrows-1
		if rc>nlines then rc=nlines
		sw.break
	sw.case "getrows"		% get the max #rows in window
		rc=nrows
		sw.break
	sw.case "relist"		% change the list
		bundle.put wg,"tlist",num
		row=1			% goto first page
		gosub txtscroll_goto
		sw.break
	sw.end

	bundle.put wg, "boff",boff
	bundle.put wg, "topw",topw
!	gr.render		% only happens for move & roll

fn.rtn rc				% return code
!-------				% touch scroll mode
txtscroll_touch:
	t0= time()
	yoff=0 : yabs=0
	do
	  gr.touch touched,x1,y1
	  if !touched then d_u.break
	  x1 = x1/scale_x
	  y1 = y1/scale_y
	  yoff = y1-y0			% +ve=pushed down -ve=pushed up
	  yabs=abs(yoff)
	  gosub txtscroll_move		% core move routine
	  gr.touch touched,x1,y2	% paused midway?
	  if touched & abs(y2-y1)<row_height/3 & time()-t0>300 then
		tapped=0			% can't be a tap
		holdboff = boff		% reset
		holdtopw = topw
		y0=y2
		t0=time()
	  endif
	until 0
	dt=time()-t0			% finger is off

	if yabs<row_height then return	% just a short distance
	tapped=0			% not a tap

	if dt<300 then		  	% if swipe
	   h = row_height*yabs/yoff + yoff/2
	   for i=1 to 30
	       yoff+=h/i
	       gosub txtscroll_move
	       gr.touch touched,x1,y2	% paused midway?
	       if touched then f_n.break
	   next
	endif
return
%--------------------
txtscroll_snap:					% snap to nearest row
	diff = mod(boff,row_height)
	if diff then
	   if diff > 0 then			% if below top
	      if diff > row_height/2 then	% and past half a row
		 boff += row_height-diff	% snap down
		 topw = floor (topw)
	      else				% not past half
		 boff -= diff			% snap up
		 topw = ceil (topw)
	      endif
	   else					% if above top
	      if diff < row_height/-2 then	% and past half a row
		 boff -= row_height+diff	% snap up
		 topw = ceil (topw)
	      else				% not past half
		 boff -= diff			% snap down
		 topw = floor (topw)
	      endif
	   endif
	endif
	btop = t+boff
	gr.modify o_bmp1, "y", btop-wh
	gr.modify o_bmp2, "y", btop
	gr.modify o_bmp3, "y", btop+wh
return
%--------------------
txtscroll_move:	% core move. (un-snapped). enter with yoff.+ve=pushdown
					% yoff must be less than 2 buffers
	if !yoff then return		% nothing to do
	ntop = holdtopw-(yoff/row_height)     % push no.of lines

	if yoff<0 & ntop+nrows>nlines+1 then ntop=nlines-nrows+1 % lastpage if push up
	if yoff<0 & ntop<topw then return	% don't over correct push up

	if ntop<1 then topw=1 else topw=ntop	% 1st page if under push down

	boff = holdboff- ((topw - holdtopw)*row_height) % (rounding error?)
	btop = t+boff
!----
	if boff <= (0-wh) then gosub txtscroll_next % bmp2 pushed up off sight
	if boff >=wh then gosub txtscroll_prev	% bmp2 pushed down off sight
!----
	gr.modify o_bmp1, "y", btop-wh		% update bitmap positions
	gr.modify o_bmp2, "y", btop
	gr.modify o_bmp3, "y", btop+wh
	gr.render
return
%--------------------
txtscroll_next:			 % load next page at bottom
	hold = o_bmp1
	o_bmp1 = o_bmp2		 % rotate bmps
	o_bmp2 = o_bmp3
	o_bmp3 = hold

	gr.get.value o_bmp3,"bitmap",bmp % get the bmp
	row = nxtrow
	gosub txtscroll_loadfwd		% load the page

	nxtrow += nrows
	prvrow += nrows
	boff+=wh			% new bmp2 pos
	btop = t+boff
	holdboff+=wh			% update reference point

	bundle.put wg,"nxtrow", nxtrow
	bundle.put wg,"prvrow", prvrow
	bundle.put wg, "o_bmp1", o_bmp1
	bundle.put wg, "o_bmp2", o_bmp2
	bundle.put wg, "o_bmp3", o_bmp3
return
%--------------------
txtscroll_prev:				% load prev page at top
	hold = o_bmp3
	o_bmp3 = o_bmp2			% rotate bmps
	o_bmp2 = o_bmp1
	o_bmp1 = hold

	gr.get.value o_bmp1,"bitmap",bmp % get the bmp
	row=prvrow
	gosub txtscroll_loadbwd		% load the page

	prvrow -= nrows
	nxtrow -= nrows
	boff-=wh			% new bmp2 pos
	btop = t-boff
	holdboff-=wh

	bundle.put wg,"nxtrow", nxtrow
	bundle.put wg,"prvrow", prvrow
	bundle.put wg, "o_bmp1", o_bmp1
	bundle.put wg, "o_bmp2", o_bmp2
	bundle.put wg, "o_bmp3", o_bmp3
return
%--------------------
txtscroll_print:			% print row at line n of bmp
	if row < 1 | row > nlines then return	% illegal row, do nothing

	dy = n*row_height		% row base (n MUST be int)
	call theme_color ("p_tsc_text1") % normal text
	gr.text.align 1
	gr.text.skew 0			% italics off
	dx = 0

	list.get tlist, row,t$
	if raw then goto txtscroll_raw
					% do special effects
	bar=is_in ("|",t$)
	if !bar then goto txtscroll_raw

	s$ = right$(t$,bar*-1)		% subtext
	t$ = left$(t$, bar-1)		% main text
	if is_in ("C",s$) then		% centre
	   gr.text.align 2
	   dx = ww/2
	endif
	if is_in ("R",s$) then	 	% right
	   gr.text.align 3
	   dx = ww
	endif
	if is_in("I",s$) then		% italics
	   gr.text.skew -0.25
	endif
	if is_in("2",s$) then		% color 2
	   call theme_color ("p_tsc_text2")
	endif
	if is_in("3",s$) then		% color 3
	   call theme_color ("p_tsc_text3")
	endif
	if is_in("V",s$) then		% reverse color
	   gr.rect o,0,dy-row_height,ww,dy	% ..the background
	   call theme_color ("p_tsc_backg") % text=bg color
	endif
txtscroll_raw:
	gr.text.draw o, dx,dy-row_height/4,t$
	gr.text.align 1
	gr.text.skew 0			% italics off
return
%--------------------
txtscroll_bg:				% paint background
	call theme_color ("p_tsc_backg")
	gr.rect o,0,0,ww,wh
return
%--------------------
txtscroll_printrow:			% reprint row in bmps
	row = num
!	if row<1 then return		% illegal row
	if row<=prvrow | row>=nxtrow then return	% buffered area ?


	top2=int(topw)+ceil(round(boff,,"HU")/row_height) % top row in bmp2

	n = row-top2+1	  		% nth row from top2

	gr.get.value o_bmp2, "bitmap", bmp
	if n<1 then			% if on bmp1
	   n+=nrows
	   gr.get.value o_bmp1, "bitmap", bmp
	endif
	if n>nrows then			% if on bmp3
	   n-=nrows
	   gr.get.value o_bmp3, "bitmap", bmp
	endif
	dy = row_height*n

	gr.bitmap.drawinto.start bmp
	call theme_color ("p_tsc_backg")	% blank line
	gr.rect o,0,dy-row_height,ww,dy

	gosub txtscroll_print		% print the line
	gr.bitmap.drawinto.end
return
%---------------------------------------
txtscroll_goto:				% set page to row
 topw = row
 boff = 0
 nxtrow = row+2*nrows
 prvrow = row-nrows-1

 row--					% go back a line
 gr.get.value o_bmp1, "bitmap", bmp	% get the bmp
 gosub txtscroll_loadbwd		% print lines backwards
!-------
 row=topw
 gr.get.value o_bmp2, "bitmap", bmp
 gosub txtscroll_loadfwd		% print lines forwards
!-------
 gr.get.value o_bmp3, "bitmap", bmp
 gosub txtscroll_loadfwd

 gr.modify o_bmp1, "y", t-wh		% reset bitmap positions
 gr.modify o_bmp2, "y", t
 gr.modify o_bmp3, "y", t+wh

 bundle.put wg,"nxtrow", nxtrow
 bundle.put wg,"prvrow", prvrow

return
%---------------------------------------
txtscroll_loadfwd:			% load fwd from row into bmp
 gr.bitmap.drawinto.start bmp
 gosub txtscroll_bg			% paint bg
 for n=1 to nrows
     if row>nlines then f_n.break
     gosub txtscroll_print
     row++
 next
 gr.bitmap.drawinto.end
return
!-------
txtscroll_loadbwd:			% load bwd from row into bmp
 gr.bitmap.drawinto.start bmp
 gosub txtscroll_bg			% paint bg
 for n=nrows to 1 step -1
     if row<1 then f_n.break
     gosub txtscroll_print
     row--
 next
 gr.bitmap.drawinto.end
return
%---------------------------------------
txtscroll_roll:			 % animate roll on/off from line num
 if num then row=num else row=topw      % num=0 means 'roll-off'
 gosub txtscroll_goto

 if num then				% init roll on
    gr.modify o_bmp1, "y", t
    gr.modify o_bmp2, "y", t+wh
 else					% init roll off
    gr.get.value o_bmp1, "bitmap", bmp
    gr.bitmap.drawinto.start bmp	% blank out above
    gosub txtscroll_bg
    gr.bitmap.drawinto.end
 endif

 gosub txtscroll_show			% make sure it's shown
 d=row_height				% scroll down for off
 if num then d*=-1			% scroll up for on

 for i = 1 to nrows
     gr.move o_bmp1,0,d
     gr.move o_bmp2,0,d
     gr.render
 next
 if !num then gosub txtscroll_hide	% hide if off

 if num then row=num else row=topw
 gosub txtscroll_goto			% repair bitmaps
return %_roll
!-------
txtscroll_hide:
	gr.hide g_all
	event_remove (wg)		% remove from detect list
return
!-------
txtscroll_show:
	gr.show g_all
	event_insert (wg)		% add back to detect list
return
!-------
fn.end
%---------------------------------------
