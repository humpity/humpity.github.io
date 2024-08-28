% gformfill.bas < HEW framework < public domain. by humpty.drivehq.com 
% v3.0
%---------------------------------------
fn.def gformfill_make (x,y,ww,wh, itmtyp,itmlab,itmval)

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 gr.text.height theight

 row_height = theight * 2
 wh = round(wh/row_height) * row_height         % round off the wdw height
 l = x
 r = x+ww-1
 t = y
 b = y+wh-1
 gr.color 255,0,0,0,0                   % make sure alpha is solid
 gr.bitmap.create bmp1, ww, wh          % bmp1 (empty)
 gr.bitmap.create bmp2, ww, wh
 gr.bitmap.create bmp3, ww, wh

 gr.clip o_clip, l, t, r, b, 0    % clip

 gr.bitmap.draw o_bmp1, bmp1, l,t-wh
 gr.bitmap.draw o_bmp2, bmp2, l,t
 gr.bitmap.draw o_bmp3, bmp3, l,t+wh

 gr.clip o, 0, 0, scr_w, scr_h, 2          % release clip
 gr.hide o_bmp1
 gr.hide o_bmp2
 gr.hide o_bmp3

 call theme_color ("p_gf_blink")        % add blinker
 gr.rect o_bn, x,y,ww+x,y+row_height
 gr.hide o_bn

 bundle.create wg                       % save objects
 bundle.put wg, "left", l
 bundle.put wg, "top", t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "theight", theight
 bundle.put wg, "itmtyp", itmtyp
 bundle.put wg, "itmlab", itmlab
 bundle.put wg, "itmval", itmval
 bundle.put wg, "o_bmp1", o_bmp1
 bundle.put wg, "o_bmp2", o_bmp2
 bundle.put wg, "o_bmp3", o_bmp3
 bundle.put wg, "o_clip", o_clip
 bundle.put wg, "o_bn",o_bn             % blinker

fn.rtn wg
fn.end %_gformfill_make
%---------------------------------------
fn.def gformfill (cmd$, data$, wg)

 gosub gf_load                          % load our form

 gosub gf_init                          % setup vars
%--------------------   % get input and act on it

 call isr_set ("gformfill")             % reset interrupt flag
 menu_pressed = 0
 do
   if bk_pressed() then d_u.break       % if back key pressed
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
   let x0 = floor(x0/scale_x)
   let y0 = floor(y0/scale_y)
                                        % if outside, treat as quit
   if (x0<left)|(x0>right)|(y0<top)|(y0>bottom) then isr_set("_") % force bakkey
   if bk_pressed() then d_u.break       % if back key pressed

   holdtopw=topw
   holdboff=boff
   yoff=0
   t0= time()
   do                                   % finger down
     gr.touch touched,x1,y1
     if !touched then d_u.break
     let x1 = floor(x1/scale_x)
     let y1 = floor(y1/scale_y)
     yoff = y1-y0                % +ve=pushed down -ve=pushed up
     gosub gf_move               % core move routine
   until 0
   t1=time()
                                        % finger up
   if abs(yoff)<row_height/3 then       % if small movement
      if (topw<>nlines-nrows+1) & (topw<>1) then
         yoff=yoff*-1                      % reverse it
         holdtopw=topw
         holdboff=boff
         gosub gf_move
      endif
      gosub gf_get               % consider it a touch
   else
      gosub gf_snap                     % snap to row
   endif

   if abs(yoff)>row_height*2 then       % if swipe
      if t1-t0 <300 then
         for i=1 to nrows
             yoff = row_height*(abs(yoff)/yoff) + yoff
             gosub gf_move
         next
      endif
   endif

 until menu_pressed
 if bk_pressed() then row=0             % if back key pressed, return 0

 gosub gf_exit
 fn.rtn row
%---------------------------------------
gf_move:        % core move. (un-snapped). enter with yoff.+ve=pushdown
                                        % yoff must be less than 2 buffers

 topw = holdtopw-(yoff/row_height)      % new top

                                        % last page if over push up
 if (topw+nrows) > (nlines+1) then topw=nlines-nrows+1
 if topw < 1 then topw = 1              % 1st page if under push down

 boff = holdboff- ((topw - holdtopw)*row_height)
 btop = top+boff
 if boff <= (0-wh) then gosub gf_loadnext  % if bmp1 pushed up off sight
 if boff >=wh then gosub gf_loadprev       % if bmp2 pushed down off sight

 gr.modify o_bmp1, "y", btop-wh         % update bitmap positions
 gr.modify o_bmp2, "y", btop
 gr.modify o_bmp3, "y", btop+wh
 if abs(yoff)<row_height/3 then return  % don't update for small movements
 gr.render
return
%--------------------
gf_snap:                                 % snap to row
        diff = mod(boff,row_height)
        if diff then
           if yoff > 0 then                     % complete push down
              if diff > 0 then diff=diff-row_height
              boff -= diff
              topw = floor (topw)
           else                                 % complete push up
              if diff < 0 then diff=row_height+diff
              boff -= diff
              topw = ceil (topw)
           endif
        endif
        btop = top+boff
        gr.modify o_bmp1, "y", btop-wh
        gr.modify o_bmp2, "y", btop
        gr.modify o_bmp3, "y", btop+wh
        gr.render
return
%--------------------
gf_loadnext:                            % load page at bottom
        hold = o_bmp1
        o_bmp1 = o_bmp2                 % rotate bmps
        o_bmp2 = o_bmp3
        o_bmp3 = hold

	gr.get.value o_bmp3,"bitmap",bmp % get the bmp
        row = nxtrow
        gosub gf_load_fwd                  % load the page

        nxtrow = nxtrow+nrows
        prvrow = prvrow+nrows
        boff = boff+wh                  % new bmp2 pos
        btop = top+boff
        holdboff = holdboff+wh          % update reference point
return
%--------------------
gf_loadprev:                               % load page at top
        hold = o_bmp3
        o_bmp3 = o_bmp2                 % rotate bmps
        o_bmp2 = o_bmp1
        o_bmp1 = hold

	gr.get.value o_bmp1,"bitmap",bmp % get the bmp
        row=prvrow
        gosub gf_load_bwd                  % load the page

        prvrow = prvrow-nrows
        nxtrow = nxtrow-nrows
        boff = boff-wh                  % new bmp2 pos
        btop = top-boff
        holdboff = holdboff-wh
return
%--------------------
gf_load_fwd:                            % load fwd from row into bmp
 gr.bitmap.drawinto.start bmp
! gosub gf_background                    % paint bg
 for n=1 to nrows
     if row>nlines then f_n.break
     gosub gf_print
     row++
 next
 gr.bitmap.drawinto.end
return
!-------
gf_load_bwd:                            % load bwd from row into bmp
 gr.bitmap.drawinto.start bmp
! gosub gf_background                    % paint bg
 for n=nrows to 1 step -1
     if row<1 then f_n.break
     gosub gf_print
     row--
 next
 gr.bitmap.drawinto.end
return
%--------------------
gf_get:                          % get touch
      x=x0-left
      y=y0-top
      row = floor( y/row_height + topw)   % nth in list
      if row > nlines then return

      list.get itmtyp,row,t$
      list.get itmlab,row,s$
      list.get itmval,row,v$

      if t$ <> "menu" then goto gf_change
                                        % blink menu and return
      y = row_height * (row-topw+1)             % nth line in wdw
      gr.modify o_bn, "top", top+y-row_height
      gr.modify o_bn, "bottom", top+y
      gr.show o_bn
      gr.render
      pause 200
      gr.hide o_bn
      gr.render
      pause 200

      menu_pressed=1
      return
gf_change:                         % make changes to dialog
      sw.begin t$
      sw.case "text_in"                 % text input
         if bk_pressed() then d_u.break   % must test if back key pressed here
                                        % otherwise it confuses with input

         input s$, v$,v$,cancelled              % text input dialog
         if !cancelled then list.replace itmval,row,v$

         gosub gf_printrow

         sw.break
      sw.case "checkbox"
         list.get itmval,row,v$
         if v$ = "0" then v$ = "1" else v$ = "0"
         list.replace itmval,row,v$

         gosub gf_printrow

         sw.break
      sw.case "counter"                         % counter
         list.get itmval,row,v$
         m$=word$(v$,2,"\\|")                   % max
         v$=word$(v$,1,"\\|")                   % num
         v = val(v$)
         if m$="" then mx=99 else mx=val(m$)    % default max is 99

         if (x<ci_left) then
            if v>1 then v=v-1                   % dec -1
         endif
         if (x > ci_right)
            if v<mx then v=v+1                  % inc +1
         endif
         if (x < nb_left+tx_height) & (x>ci_left) then
           if v>10 then v=v-10                  % dec -10
         endif
         if (x > nb_right-tx_height) & (x<ci_right) then
            if v<mx-10 then v=v+10         % inc +10
         endif
         v$ = right$(format$("%%",v),2)
         if m$<>"" then v$=v$+"\|"+m$
         list.replace itmval,row,v$             % new value

         gosub gf_printrow
         sw.break

      sw.case "radio"
         r=int(row)
         for row=1 to nlines                    % look for all radios
             list.get itmtyp,row,t$
             if t$ = "radio" then
                if (row=r) then v$ = "1" else v$ = "0"
                list.replace itmval,row,v$
                gosub gf_printrow
             endif % radio
         next
         sw.break
      sw.end
      gr.render
return
%---------------------------------------
gf_printrow:                            % find bmp, print row
        if row<=prvrow | row>=nxtrow then return   % ignore unbuffered area

        n = row-topw+1          % nth row from topw
        gr.get.value o_bmp2, "bitmap", bmp
        dy = n*row_height-boff                  % y offset from bmp2
        if dy <= 0 then         % if on bmp1
           dy = dy+wh
	   gr.get.value o_bmp1, "bitmap", bmp
        endif
        if dy > wh then         % if on bmp3
           dy = dy-wh
	   gr.get.value o_bmp3, "bitmap", bmp
        endif

        n = dy/row_height               % nth row from bmp top

        gr.bitmap.drawinto.start bmp

        gosub gf_print                  % print the line
        gr.bitmap.drawinto.end
return
%---------------------------------------
gf_print:                               % print row at line n of bmp

     list.get itmtyp,row,t$        % type   e.g checkbox|text
     list.get itmlab,row,s$        % label  e.g blue    |enter name:
     list.get itmval,row,v$        % value  e.g "1"     |john

     x = indent
     y = row_height*n -1                % base line
     dy= y-row_height/3                 % solo text y pos
     dy1 = y-row_height/2               % main text y pos
     dy2 = y-row_height/8               % sub  text y pos

     call theme_color ("p_gf_backgnd")      % blank it out first
     gr.rect o,0,y-row_height+1,ww,y

     gr.text.size theight
     gr.text.align 1
        
     if t$ = "menu" | t$ = "title" then % position labels (only menus & titles)

        fmt=is_in ("|",v$)                 % if format sub cmd
        if fmt then
           f$ =mid$(v$,fmt+1)              % split type,format
           v$=mid$(v$,1,fmt-1)
        endif
        if v$ = "C" then
           gr.text.align 2
           x = ww/2
        endif
        if v$ = "R"  then
           gr.text.align 3
           x = ww-indent
        endif
        if fmt & f$="B" then fmt=1 else fmt=0   % only support border cmd
     endif %_menu or title

     if left$(s$,1) = "~" then          % ignore line seperator ?
        s$ = mid$ (s$,2)
     else
        call theme_color ("p_gf_line")
        gr.set.stroke 1
        gr.line o, indent,y,ww-indent,y     % seperation line
     endif

     if t$="title" then
        theme_color ("p_gf_title_bg")           % title bg
        if fmt then                             % border
           gr.rect o,indent/2,y-row_height+indent/2,ww-indent/2,y+1
        else
           gr.rect o,0,y-row_height,ww,y+1      % no border
        endif
        theme_color ("p_gf_title_fg")           % title fg
     else
        theme_color ("p_gf_label")              % label fg
     endif

     gr.text.size theight
     gr.set.stroke 0

     subtxt=is_in ("|",s$)              % if subtext embedded in label
     if (subtxt) then
        sb$ =mid$(s$,subtxt+1)          % split label,subtext
        s$=mid$(s$,1,subtxt-1)

        gr.text.draw o, x,dy1,s$        % print main label higher

        gr.text.size theight*2/3      % subtext size
        gr.text.draw o, x,dy2,sb$       % print subtext lower
        gr.text.size theight
     else                               % solo label
        gr.text.draw o, x,dy,s$
     endif %_subtxt

     sw.begin t$
     sw.case "text_in"
        gr.text.size theight
        ov$ = v$
        while len(ov$)
              gr.text.width w,ov$
              if w >= (tx_right-tx_left-theight/6) then
                 ov$ = left$(ov$,len(ov$)-1)    % shorten text
              else
                 w_r.break
              endif
        repeat
                                             % text input cropped
        call theme_color ("p_gf_txinbg")
        gr.rect o, tx_left, y-row_height*5/6, tx_right, y-row_height/6
        call theme_color ("p_gf_txinfg")
        gr.text.draw o, tx_left+theight/6, dy, ov$
        sw.break

     sw.case "checkbox"

        call theme_color ("p_gf_ckbor")
        gr.rect o, ck_left,y-row_height*5/6, ck_right,y-row_height/6

        call theme_color ("p_gf_ckon")                  % tick on
        if v$ = "0" then theme_color ("p_gf_backgnd")   % tick off
        gr.rect o, tk_left,y-row_height*5/6+ck_height/4,tk_right,y-row_height/6-ck_height/4
        sw.break

     sw.case "counter"
        m$ =  word$(v$,2,"\\|")                 % max
        v$ =  word$(v$,1,"\\|")                 % num
        v = val(v$)
        if m$<>"" then                          % if max supplied
           if val(m$) > 99 then m$="99"
           list.replace itmval, row, v$+"\|"+m$
        endif

        call theme_color ("p_gf_ckbor")  % p_count_of
        gr.rect o, co_left,y-row_height*5/6, co_right,y-row_height/6

        call theme_color ("p_gf_rdbor")  % p_count_if
        gr.rect o, ci_left,y-row_height*5/6, ci_right,y-row_height/6

        call theme_color ("p_gf_nb")  % p_count_nb
        gr.rect o, nb_left,y-row_height*5/6,nb_right,y-row_height/6
   
        call theme_color ("p_gf_nf")  % p_count_nf
        gr.text.draw o,       nf_x-theight, dy, "-          +"
        gr.text.draw o, nf_x, dy, v$             % number fg
        sw.break

     sw.case "radio"
        call theme_color ("p_gf_rdbor")  % border
        gr.circle o, rd_x,y-row_height/2,rd_radius
   
        call theme_color ("p_gf_rdon")  % on
        if v$ = "0" then call theme_color ("p_gf_backgnd")  % off
        gr.circle o, rd_x,y-row_height/2,rd_radius/2
        sw.break
     sw.end
return
%--------------------
gf_background:                           % paint background
        gr.bitmap.drawinto.start bmp
        call theme_color ("p_gf_backgnd")
        gr.rect o,0,0,ww,wh
        gr.bitmap.drawinto.end
return
%---------------------------------------
gf_init:                         % setup form vars

 indent = theight/4                        % left/right border
 tx_left = ww/2
 tx_right = ww-indent
 tx_max   = (tx_right - tx_left)/theight % max chars for text input

 ck_height = row_height*4/6             % checkbox height
 ck_left   = ww-ck_height-indent        % checkbox left x pos
 ck_right  = ck_left + ck_height        % checkbox right x pos
 tk_height = ck_height/2                % tick (really a square)
 tk_left   = ck_left+ck_height/4
 tk_right  = tk_left+ck_height/2

 ct_height = row_height*4/6             % counter height
 co_left   = ww-8*theight-indent        % counter o-frame left
 co_right  = ww-indent                  % counter o-frame right

 ci_left   = co_left + 2*theight        % counter i-frame left
 ci_right  = ci_left + 4*theight        % counter i-frame right

 nb_left   = ci_left + 1*theight        % counter number bg left
 nb_right  = ci_left + 3*theight        % counter number bg right
 nf_x      = nb_left + 0.4*theight      % counter number fg x

 rd_radius = row_height/3
 rd_x      = ww-rd_radius-indent
                                        % init bmps
!-------
 gr.get.value o_bmp1,"bitmap",bmp1
 bmp=bmp1
 gosub gf_background                     % paint bg
!-------
 gr.get.value o_bmp2,"bitmap",bmp2
 bmp=bmp2
 row =1
 gosub gf_background                     % paint bg
 gosub gf_load_fwd                      % fill bmp2
!-------
 gr.get.value o_bmp3,"bitmap",bmp3
 bmp=bmp3
 gosub gf_background                     % paint bg
 gosub gf_load_fwd                      % fill bmp3
!-------
 no_trans=1                             % no transition ?
 if cmd$="input" then
    no_trans=0
    sw.begin data$
    sw.case "left"
       j=left-ww
       k=left
       l=ww/10
       p$="x"
       sw.break
    sw.case "right"
       j=right
       k=left
       l= -1 * ww/10
       p$="x"
       sw.break
    sw.case "top"
       j=top-wh
       k=top
       l=wh/10
       p$="y"
       sw.break
    sw.case "bottom"
       j=top+wh
       k=top
       l= -1 * wh/10
       p$="y"
       sw.break
    sw.default
       no_trans=1               % no transition found
    sw.end
 endif
 if no_trans then goto gf_open

 gr.show o_bmp2              % show transitions
 for i= j to k step l
     gr.modify o_bmp2, p$, i
     gr.render
 next
gf_open:
 gr.modify o_bmp1, "x", left, "y", top-wh
 gr.modify o_bmp2, "x", left, "y", top
 gr.modify o_bmp3, "x", left, "y", top+wh
 gr.show o_bmp1
 gr.show o_bmp2
 gr.show o_bmp3
 gr.render
return  %_gf_init
%-----------------------
gf_load:                                % load the form objects

 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "scale_x",scale_x        % assume scaling
 bundle.get 1, "scale_y",scale_y        % otherwise these must be 1:1

 bundle.get wg, "left", left
 bundle.get wg, "top", top
 bundle.get wg, "right", right
 bundle.get wg, "bottom", bottom
 bundle.get wg, "theight", theight
 bundle.get wg, "itmtyp", itmtyp
 bundle.get wg, "itmlab", itmlab
 bundle.get wg, "itmval", itmval
 bundle.get wg, "o_bmp1", o_bmp1
 bundle.get wg, "o_bmp2", o_bmp2
 bundle.get wg, "o_bmp3", o_bmp3
 bundle.get wg, "o_clip", o_clip
 bundle.get wg, "o_bn",o_bn             % blinker

 list.size itmtyp,nlines                 % actual list size
 row_height = theight * 2
 ww = right-left+1
 wh = bottom-top+1
 nrows = floor(wh/row_height)                 % max rows fills wdw

 topw = 1                               % top line of wdw
 boff = 0                               % bmp2 y-offset from t
 nxtrow = 2*nrows+1                     % next row unbuffered
 prvrow = 0-nrows                       % previous row unbuffered

return  %_gf_load
%-----------------------
gf_exit:                                % exit the form

 no_trans=1                             % no transition ?
 if cmd$="input" then
    no_trans=0
    sw.begin data$
    sw.case "left"
       j=left
       k=left-ww-10
       l=-1 * ww/10
       p$="x"
       cj=j+ww
       ck=k+ww
       c$="right"
       sw.break
    sw.case "right"
       j=left
       k=right+10
       l=ww/10
       cj=j
       ck=k
       p$="x"
       c$="left"
       sw.break
    sw.case "top"
       j=top
       k=top-wh-10
       l=-1 * wh/10
       p$="y"
       cj=j+wh
       ck=k+wh
       c$="bottom"
       sw.break
    sw.case "bottom"
       j=top
       k=bottom+10
       l=wh/10
       p$="y"
       cj=j
       ck=k
       c$="top"
       sw.break
    sw.default
       no_trans=1
    sw.end
 endif

 if no_trans then goto gf_close
 o = o_bmp2
 if boff then
    p$=c$                       % if bmp2 not whole, slide clip instead
    j = cj
    k = ck
    o = o_clip
 endif
 for i= j to k step l           % do slide out
     gr.modify o, p$, i
     gr.render
 next
 gr.modify o_bmp2, "x", left, "y", top
 gr.modify o_clip, "left", left, "top", top, "right",right, "bottom",bottom
gf_close:
 gr.hide o_bmp1
 gr.hide o_bmp2
 gr.hide o_bmp3
 gr.render
return  %_gf_exit
%---------------------------------------
fn.end  % gformfill
