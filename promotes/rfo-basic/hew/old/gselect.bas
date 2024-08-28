% gselect.bas < HEW framework < public domain. by humpty.drivehq.com 
% v3
%---------------------------------------
fn.def gselect (cmd$, label$)

 gosub gselect_load                   % load our form
                                      % get input and act on it
 menu_pressed = 0
 boff=0
 offset=0
 do
   row = 0
   do                                   % wait for touch
     if bk_pressed() then d_u.break     % if back key pressed

     gr.touch touched, x0, y0
     pause 50                           % suppress cpu hack

     if background() & in_bg=0 then     % if app was put in bg
        in_bg=1                         % set flag
     else
        if !background() & in_bg=1 then      % if returned from bg
           gr.render                         % redraw graphics screen
           in_bg=0                           % re-toggle bg flag
        endif
     endif
   until touched

   let x0 = x0/scale_x
   let y0 = y0/scale_y
   if (x0<left)|(x0>right)|(y0<top)|(y0>bottom) then isr_set("_") % force bakkey
   if bk_pressed() then d_u.break       % if back key pressed

   do                                   % finger down

     gr.touch touched,x1,y1
     if !touched then d_u.break
     let x1 = x1/scale_x
     let y1 = y1/scale_y
     yoff = y1-y0                       % +ve=pushed down -ve=pushed up
     gosub gselect_move                 % core move routine
   until 0
                                        % finger is off
   if abs(yoff)<row_height/3 then
      gosub gselect_get                 % hardly_moved=touch
   endif

   boff = offset                        % accept move

 until menu_pressed
 if bk_pressed() then row=0             % if back key pressed, return 0

 gosub gselect_exit
 fn.rtn row
%---------------------------------------
gselect_move:        % core move. (un-snapped). enter with yoff.+ve=pushdown
                                        % yoff must be less than 2 buffers
 offset=boff+yoff

 if (offset) < (0-bheight+wh) then offset=0-bheight+wh % if pushed up to limit
 if (offset) > 0 then offset=0          % if pushed down to limit
 gr.modify o_bmp, "y", top+offset       % update bitmap position
 gr.render
return
%--------------------
gselect_get:                          % get touch
      x=x0
      y=y0
      row = 1+floor((y-top-boff) / row_height)
      if row > lsize | row <2 then return
      y = (row_height * row)-1          % base line
      dy= y-row_height/3                % solo text y pos

                                        % blink menu and return
      gr.bitmap.drawinto.start bmp

      theme_color ("p_gf_blink")        % blinker

      gr.rect o, border, y-row_height*0.9, ww-1-border, y-row_height*0.1
      gosub gselect_printrow
      gr.render
      pause 200
      theme_color ("p_gf_backgnd")      % background
      gr.rect o, border, y-row_height, ww-1-border, y
      gosub gselect_printrow
      gr.render
      pause 200
      gr.bitmap.drawinto.end

      row=row-1                         % return the nth item (-title)
      menu_pressed=1
      return
%---------------------------------------
gselect_printrow:                       % print this row

     s$=label$[row]
     y = (row_height * row)-1           % base line
     dy= y-row_height*0.3                 % solo text y pos

     gr.text.size theight
     gr.text.align 2                    % default centered
     x = ww/2
     if fmt$ = "L" then                 % left align
        gr.text.align 1
        x = indent
     endif
     if fmt$ = "R"  then                % right align
        gr.text.align 3
        x = ww-indent
     endif

     gr.set.stroke 0
     if row=1 then

        theme_color ("p_gf_title_bg")           % title bg
        gr.rect o, border, y-row_height+1+border, ww-1-border, y

        theme_color ("p_gf_line")               % separation line
        gr.line o, border,y,ww-1-border,y

        theme_color ("p_gf_title_fg")      % title fg
     else
        theme_color ("p_gf_line")               % separation line
!        if row<>lsize then gr.line o, indent,y,ww-indent,y
        gr.line o, indent,y,ww-indent,y
        theme_color ("p_gf_label")              % label
     endif
     gr.text.draw o, x,dy,s$                    % text

return
%---------------------------------------
gselect_load:                         % load the form

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "scale_x",scale_x        % assume scaling
 bundle.get 1, "scale_y",scale_y        % otherwise these must be 1:1

 Gr.GetDL dl_arr[],1
 gr.text.height theight
 row_height = theight * 2
 maxw = scr_w-2*row_height
 maxh = scr_h-2*row_height

 fmt$=""
 if cmd$="" | (ascii(cmd$)=124) then cmd$="center"+cmd$   % don't allow empty cmd
 fmt$ = word$(cmd$, 2, "\\|")          % get embedded format if any
 cmd$=word$(cmd$, 1, "\\|")             % and strip it off cmd

 split label$[], label$, "\\|"
 array.length lsize, label$[]           % actual list size
 wmax=0
 for i=1 to lsize                       % find widest
     gr.text.width w,label$[i]
     if w>wmax then wmax=w
 next
 ww= wmax+theight                       % wdw width
 indent = theight/4                        % left/right border
 if ww>maxw then ww=maxw                % if too wide

 bheight = lsize*row_height             % bmp height
 wh = bheight
 if wh>maxh then wh=maxh                % if too tall

                                        % default to center of screen
 top = floor(scr_h/2) - floor(wh/2)
 left = floor(scr_w/2)-floor(ww/2)

 if cmd$= "left" then left=0
 if cmd$= "right" then left=scr_w-ww
 if cmd$= "top" then top=0
 if cmd$= "bottom" then top=scr_h-wh

 right = left+ww-1
 bottom = top+wh-1
 nrows = wh/row_height                  % max rows fills wdw

 theme_color ("p_gf_title_bg")           % border
 gr.rect o_bord, left-1,top,right+1,bottom+2
 gr.bitmap.create bmp, ww, bheight      % create bitmap
 gr.clip o_clip, left, top, right, bottom, 0    % clip
 gr.bitmap.draw o_bmp, bmp, left,top
 gr.clip o_clip, 0, 0, scr_w, scr_h, 2  % release clip

 gr.bitmap.drawinto.start bmp
 theme_color ("p_gf_backgnd")           % fill background
 gr.rect o, 0,0, ww-1, bheight

 for row=1 to lsize                     % fill form
     gosub gselect_printrow
 next
 gr.bitmap.drawinto.end
                                        
 if is_in (cmd$,"left,right,top,bottom") then no_trans=0 else no_trans=1
 if no_trans then goto gf_open          % no transition

 if cmd$= "left" then
    gr.modify o_bmp, "x", left-ww
    dx=ww/10
    dy=0
 endif
 if cmd$= "right" then
    gr.modify o_bmp, "x", right
    dx= ww/-10
    dy=0
 endif
 if cmd$= "top" then
    gr.modify o_bmp, "y", top-wh
    dx=0
    dy=wh/10
 endif
 if cmd$= "bottom" then
    gr.modify o_bmp, "y", top+wh
    dx=0
    dy=wh/-10
 endif

 gr.hide o_bord
 gr.show o_bmp                          % show transition
 for i= 1 to 10
     gr.move o_bmp, dx,dy
     gr.render
 next
gf_open:
 gr.modify o_bmp, "x", left, "y", top
 gr.show o_bmp
 gr.show o_bord
 gr.render
return  %_gformfill_load
%-----------------------
gselect_exit:                           % exit the form

 gr.hide o_bord
 if no_trans then goto gf_close
 if cmd$="left" then
    gr.modify o_bmp, "x", left
    dx=ww/-10
    dy=0
 endif
 if cmd$="right" then
    gr.modify o_bmp, "x", left
    dx=ww/10
    dy=0
 endif
 if cmd$="top" then
    gr.modify o_bmp, "y", top
    dx=0
    dy=wh/-10
 endif
 if cmd$="bottom" then
    gr.modify o_bmp, "y", top
    dx=0
    dy=wh/10
 endif

 for i= 1 to 10
     gr.move o_bmp, dx,dy
     gr.render
 next
gf_close:
 gr.modify o_bmp, "x", left, "y", top
 gr.hide o_bmp
 gr.bitmap.delete bmp                   % release bmp
 undim label$[]
 Gr.NewDL dl_arr[]                      % restore display
 gr.render
return  %_gformfill_exit
%---------------------------------------
fn.end  % gselect


