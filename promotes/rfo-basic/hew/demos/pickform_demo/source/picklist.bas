% picklist.bas < HEW framework < public domain. by humpty.drivehq.com
% v3.0
%---------------------------------------
fn.def picklist (cmd$, label$)

 gosub picklist_load			% load our form
					% get input and act on it
 menu_pressed = 0
 boff=0
 offset=0
 do
   row = 0
   do					% wait for touch
     if bk_pressed() then d_u.break	% if back key pressed

     gr.touch touched, x0, y0
     pause 50				% suppress cpu hack

     if background() & in_bg=0 then	% if app was put in bg
	in_bg=1				% set flag
     else
	if !background() & in_bg=1 then	% if returned from bg
	   gr.render			% redraw graphics screen
	   in_bg=0			% re-toggle bg flag
	endif
     endif
   until touched

   let x0 = x0/scale_x
   let y0 = y0/scale_y
   if (x0<left)|(x0>right)|(y0<top)|(y0>bottom) then isr_set("_") % force bakkey
   if bk_pressed() then d_u.break	% if back key pressed

   do					% finger down

     gr.touch touched,x1,y1
     if !touched then d_u.break
     let x1 = x1/scale_x
     let y1 = y1/scale_y
     yoff = y1-y0			% +ve=pushed down -ve=pushed up
     gosub picklist_move		% core move routine
   until 0
					% finger is off
   if abs(yoff)<rh/3 then
      gosub picklist_get		% hardly_moved=touch
   endif

   boff = offset			% accept move

 until menu_pressed
 if bk_pressed() then row=0		% if back key pressed, return 0

 gosub picklist_exit
 isr_set("")				% reset backkey interrupt

 fn.rtn row
%---------------------------------------
picklist_move:	% core move. (un-snapped). enter with yoff.+ve=pushdown
					% yoff must be less than 2 buffers
 offset=boff+yoff

 if (offset) < (0-bheight+wh) then offset=0-bheight+wh % if pushed up to limit
 if (offset) > 0 then offset=0		% if pushed down to limit
 gr.modify o_bmp, "y", top+bw+offset 	% update bitmap position
 gr.render
return
%--------------------
picklist_get:				% get touch

	y=y0-top-bw  : if y<0 then y=0
	row = 1+floor((y-boff)/rh) 	% nth in list

	if row > lsize | row <2 then return
	y = (rh * row)-1	% base line
	dy= y-rh*0.3		% solo text y

					% blink menu and return
	gr.bitmap.drawinto.start bmp

	call theme_swap ("p_pl_backg","p_pl_label")
	gosub picklist_printrow		% press
	gr.render
	pause 125
	call theme_swap ("p_pl_backg","p_pl_label")
	gosub picklist_printrow		% un-press
	gr.render
	pause 100			% delay before close
	gr.bitmap.drawinto.end

	row--			 % return the nth item (-title)
	menu_pressed=1
return
%---------------------------------------
picklist_printrow:		       % print this row

	s$=label$[row]
	y = rh*row-1		% base line
	dy= y-rh/3		% solo text y

	if ascii(s$)=126 then		% ignore line seperator ?
		s$ = mid$ (s$,2)
		sep=0
	else
		sep=1
	endif
	gr.text.align 2			% centered
	x = ww/2

	gr.set.stroke bw/2			% min=0
	if row=1
		theme_color ("p_pl_title_bg")		% title bg
		gr.rect o,0,y-rh+1,ww,y+1

		if sep then
			theme_color ("p_pl_line")	% long line
			gr.line o, 0,y,ww,y
		endif
		theme_color ("p_pl_title_fg") 		% title fg
	else
		call theme_color ("p_pl_backg") 	% blank bg
		gr.rect o,0,y-rh+1,ww,y+1
		if row<lsize & sep
			theme_color ("p_pl_line")	% short line
			gr.line o, indent,y,ww-indent,y
		endif
		theme_color ("p_pl_label")		% label
	endif
	gr.set.stroke 1
	gr.text.draw o, x,dy,s$		% text
return
%---------------------------------------
picklist_load:				% load the form

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "scale_x",scale_x	% assume scaling
 bundle.get 1, "scale_y",scale_y	% otherwise these must be 1:1
 bundle.get 1, "sbar",sbar		% status bar height

 Gr.GetDL dl_arr[],1
 gr.text.height theight			% use current font size
 theight=int(theight)
 rh = theight * 2
 maxw = scr_w-2*rh			% limit width
 maxh = scr_h-sbar-2*rh			% limit height

 if cmd$="" | (ascii(cmd$)=124) then cmd$="none"+cmd$   % don't allow empty cmd
 fmt$ = word$(cmd$, 2, "\\|")		% get embedded data if any
 cmd$=word$(cmd$, 1, "\\|")		% and strip it off cmd

 split label$[], label$, ","
 array.length lsize, label$[]		% actual list size
 wmax=0
 for i=1 to lsize			% find widest
     gr.text.width w,label$[i]
     if w>wmax then wmax=w
 next
 ww= wmax+theight			% wdw width + padding
 if ww>maxw then ww=maxw		% if too wide

 bheight = lsize*rh			% bmp height
 wh = bheight
 if wh>maxh then wh=maxh		% if too tall

 indent = int(theight/4)		% left/right line indent

 bw = int(theight/10)			% border width
 x=-1 : y=-1				% default positions incl.border
 if cmd$= "left" then x=0		% slide from left (force under)
 if cmd$= "right" then x=scr_w		% slide from right (force over)
 if cmd$= "top" then y=0		% slide from top (force under)
 if cmd$= "bottom" then y=scr_h		% slide from bottom (force over)

 cx=0: cy=0
 if fmt$<>"" then			% if position given
	x$ = word$ (fmt$, 1,",")
	y$ = word$ (fmt$, 2,",")

	cx= (ascii(x$)=126)
	if cx then x$=mid$(x$,2)	% center justify on x ?
	cy=(ascii(y$)=126)
	if cy then y$=mid$(y$,2)	% center justify on y ?

	x=val(x$) : y=val(y$)		% get unformatted positions
 endif
 x=int(x) : y=int(y)

 if x=-1 then x=0.5*(scr_w-ww-bw)	% x center
 if y=-1 then y=0.5*(scr_h-wh-bw)	% y center
					% right,bottom justify
 if x<-1 then x=-1*x-ww-bw*2+1		% x is right (inclusive)
 if y<-1 then y=-1*y-wh-bw*2+1		% y is bottom (inclusive)

 if cx then x-=0.5*(ww+bw)		% center justify
 if cy then y-=0.5*(wh+bw)

 if x<bw then x=bw			% force inside screen with min gap bw
 if y<sbar+bw then y=sbar+bw
 if x+ww+bw*3 > scr_w then x=scr_w-ww-bw*3
 if y+wh+bw*3 > scr_h then y=scr_h-wh-bw*3

 left = x
 top = y
 right = x+ww+bw*2-1
 bottom = y+wh+bw*2-1

 theme_color ("p_pl_border")		% border
 gr.rect o_bord, left,top,right+1,bottom+1
 gr.bitmap.create bmp, ww, bheight      % create bitmap
 gr.clip.start o_clip1, left+bw,top+bw, right-bw+1,bottom-bw+1, 0    % clip
 gr.bitmap.draw o_bmp, bmp, left+bw,top+bw
%~ gr.clip o_clip2, 0, 0, scr_w, scr_h, 2  % release clip
 gr.clip.end o_clip2						% release clip

 gr.bitmap.drawinto.start bmp
 theme_color ("p_pl_backg")		% fill background
 gr.rect o, 0,0, ww, bheight

 for row=1 to lsize			% fill form
     gosub picklist_printrow
 next
 gr.bitmap.drawinto.end

 no_trans=0
 sw.begin cmd$
 sw.case "left"
	gr.modify o_bmp, "x", left-ww : dx=ww/8 : dy=0
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
 if no_trans then goto picklist_open

 gr.hide o_bord
 gr.show o_bmp				% show transition

 for i= 1 to 8
     gr.move o_bmp, dx,dy
     gr.render
 next
picklist_open:
 gr.modify o_bmp, "x", left+bw, "y", top+bw
 gr.show o_bmp
 gr.show o_bord
 gr.render
return  %_picklist_load
%-----------------------
picklist_exit:				% exit the form

 sw.begin cmd$
 sw.case "left"
	dx=ww/-8 : dy=0
	sw.break
 sw.case "right"
	dx=ww/8 : dy=0
	sw.break
 sw.case "bottom"
	dx=0 : dy=wh/8
	sw.break
 sw.case "top"
	dx=0 : dy=wh/-8
	sw.break
 sw.default
	no_trans=1
 sw.end

 gr.hide o_bord
 if no_trans then goto picklist_close
 for i= 1 to 8
	gr.move o_bmp, dx,dy
	gr.render
 next
picklist_close:
 gr.hide o_bmp
 gr.bitmap.delete bmp			% release memory
 undim label$[]
 Gr.NewDL dl_arr[]			% restore display
 gr.render
return  %_picklist_exit
%---------------------------------------
fn.end  % picklist

