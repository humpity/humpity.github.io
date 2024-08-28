% picklist.bas < HEW framework < public domain. by humpty.drivehq.com
% v1.2
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
   if abs(yoff)<row_height/3 then
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
 gr.modify o_bmp, "y", top+offset 	% update bitmap position
 gr.render
return
%--------------------
picklist_get:				% get touch
      x=x0
      y=y0
      row = 1+floor((y-top-boff) / row_height)
      if row > lsize | row <2 then return
      y = (row_height * row)-1		% base line
      dy= y-row_height/3		% solo text y

					% blink menu and return
      gr.bitmap.drawinto.start bmp

      theme_color ("p_pf_blink")	% blinker

      gr.rect o, 0, y-row_height*0.9, ww-1, y-row_height*0.1
      gosub picklist_printrow
      gr.render
      pause 200
      theme_color ("p_pf_backgnd")      % background
      gr.rect o, 0, y-row_height, ww-1, y
      gosub picklist_printrow
      gr.render
      pause 200
      gr.bitmap.drawinto.end

      row=row-1			 % return the nth item (-title)
      menu_pressed=1
      return
%---------------------------------------
picklist_printrow:		       % print this row

     s$=label$[row]
     y = (row_height * row)-1		% base line
     dy= y-row_height*0.3		% solo text y

     gr.text.size theight
     gr.text.align 2			% centered
     x = ww/2
     gr.set.stroke 0
     if row=1 then

	theme_color ("p_pf_title_bg")	% title bg
	gr.rect o, -1, y-row_height+1, ww, y

	theme_color ("p_pf_line")	% separation line
	gr.line o, 0,y,ww-1,y

	theme_color ("p_pf_title_fg") 	% title fg
     else
	theme_color ("p_pf_line")	% separation line
	gr.line o, indent,y,ww-indent,y
	theme_color ("p_pf_label")	% label
     endif
     gr.text.draw o, x,dy,s$		% text
return
%---------------------------------------
picklist_load:				% load the form

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "scale_x",scale_x	% assume scaling
 bundle.get 1, "scale_y",scale_y	% otherwise these must be 1:1

 Gr.GetDL dl_arr[],1
 gr.text.height theight			% use current font size
 row_height = theight * 2
 maxw = scr_w-2*row_height
 maxh = scr_h-2*row_height

 if cmd$="" | (ascii(cmd$)=124) then cmd$="center"+cmd$   % don't allow empty cmd
 fmt$ = word$(cmd$, 2, "\\|")		% get embedded data if any
 cmd$=word$(cmd$, 1, "\\|")		% and strip it off cmd

 split label$[], label$, ","
 array.length lsize, label$[]		% actual list size
 wmax=0
 for i=1 to lsize			% find widest
     gr.text.width w,label$[i]
     if w>wmax then wmax=w
 next
 ww= wmax+theight			% wdw width
 indent = theight/4			% left/right border
 if ww>maxw then ww=maxw		% if too wide

 bheight = lsize*row_height		% bmp height
 wh = bheight
 if wh>maxh then wh=maxh		% if too tall

					% default to center of screen
 top = floor(scr_h/2) - floor(wh/2)
 left = floor(scr_w/2)-floor(ww/2)

 if cmd$= "left" then left=2
 if cmd$= "right" then left=scr_w-ww-2
 if cmd$= "top" then top=2
 if cmd$= "bottom" then top=scr_h-wh-2

 if fmt$<>"" then			% if position given
	x = val (word$ (fmt$, 1,","))	% get position
	y = val (word$ (fmt$, 2,","))
	if x=-1 then x=left		% x center
	if y=-1 then y=top		% y center
	if x+ww > scr_w then x=scr_w-ww-2	% force inside screen
	if y+wh > scr_h then y=scr_h-wh-2
	if x<0 then x=2
	if y<0 then y=2
	left = x : top=y
 endif
 right = left+ww-1
 bottom = top+wh-1

 theme_color ("p_pf_title_bg")		% title bg and border
 gr.set.stroke 2
 gr.rect o_bord, left-2,top,right+2,bottom+2

 gr.bitmap.create bmp, ww, bheight      % create bitmap
 gr.clip o_clip1, left, top, right, bottom, 0    % clip
 gr.bitmap.draw o_bmp, bmp, left,top
 gr.clip o_clip2, 0, 0, scr_w, scr_h, 2  % release clip

 gr.bitmap.drawinto.start bmp
 theme_color ("p_pf_backgnd")		% fill background
 gr.rect o, 0,0, ww-1, bheight

 for row=1 to lsize			% fill form
     gosub picklist_printrow
 next
 gr.bitmap.drawinto.end

 if is_in (cmd$,"left,right,top,bottom") then no_trans=0 else no_trans=1
 if no_trans then goto picklist_open	% no transition

 sw.begin cmd$
 sw.case "left"
    gr.modify o_bmp, "x", left-ww
    dx=ww/8
    dy=0
    sw.break
 sw.case "right"
    gr.modify o_bmp, "x", right
    dx= ww/-8
    dy=0
    sw.break
 sw.case "bottom"
    gr.modify o_bmp, "y", top+wh
    dx=0
    dy=wh/-8
    sw.break
 sw.case "top"
    gr.modify o_bmp, "y", top-wh	% drop from above
    dx=0
    dy=wh/8
    sw.break
 sw.end
 gr.hide o_bord
 gr.show o_bmp				% show transition
 for i= 1 to 8
     gr.move o_bmp, dx,dy
     gr.render
 next
picklist_open:
 gr.modify o_bmp, "x", left, "y", top
 gr.show o_bmp
 gr.show o_bord
 gr.render
return  %_picklist_load
%-----------------------
picklist_exit:				% exit the form

 gr.hide o_bord
 if no_trans then goto picklist_close
 sw.begin cmd$
 sw.case "left"
    gr.modify o_bmp, "x", left
    dx=ww/-8
    dy=0
    sw.break
 sw.case "right"
    gr.modify o_bmp, "x", left
    dx=ww/8
    dy=0
    sw.break
 sw.case "bottom"
    gr.modify o_bmp, "y", top
    dx=0
    dy=wh/8
    sw.break
 sw.case "top"
    gr.modify o_bmp, "y", top
    dx=0
    dy=wh/-8
    sw.break
 sw.end
 for i= 1 to 8
     gr.move o_bmp, dx,dy
     gr.render
 next
picklist_close:
 gr.modify o_bmp, "x", left, "y", top
 gr.hide o_bmp
 gr.bitmap.delete bmp			% release bmp
 undim label$[]
 Gr.NewDL dl_arr[]			% restore display
 gr.render
return  %_picklist_exit
%---------------------------------------
fn.end  % picklist

