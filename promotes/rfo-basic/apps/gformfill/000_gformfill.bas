! gformfill.bas v1.0
! Fill form options using graphics.(by humpty/freeware/no restrictions.)
! (see bottom for example call)
%---------------------------------------
fn.def gformfill (itmtyp, itmlab, itmval)

 fn_scope$ = "gformfill"                % necessary for onbackkey (see bottom)
 list.size itmtyp,lsize

 gr.open 255,0,0,0,0
 gr.orientation 1
 gr.cls
 pause 500

 gr.screen scr_width, scr_height
 nrows = floor(scr_height / 48)          % scale # of rows here

 row_height = scr_height / nrows+1

 indent = scr_width/50                   % left/right border

 tx_height = row_height / 2
 gr.text.size tx_height

 tx_left = scr_width/2
 tx_right = scr_width-indent
 tx_max   = (tx_right - tx_left)/tx_height % max chars for text input

 ck_height = row_height*4/6             % checkbox height
 ck_left   = scr_width-ck_height-indent % checkbox left x pos
 ck_right  = ck_left + ck_height        % checkbox right x pos
 tk_height = ck_height/2                % tick (really a square)
 tk_left   = ck_left+ck_height/4
 tk_right  = tk_left+ck_height/2

 rd_radius = row_height/3
 rd_x      = scr_width-rd_radius-indent
%----------------
 gr.color 255,255,255,255,0     % pre-defined paint objects
                                % (becareful with the ordering!)
 gr.text.align 2
 gr.paint.get p_label_center
 gr.text.align 3
 gr.paint.get p_label_right
 gr.text.align 1
 gr.paint.get p_label_left

 gr.color 255,200,200,200,0         % subtext color
 gr.text.align 2
 gr.text.size tx_height*2/3
 gr.paint.get p_subtxt_center
 gr.text.align 3
 gr.paint.get p_subtxt_right
 gr.text.align 1
 gr.paint.get p_subtxt_left

 gr.text.size tx_height
 gr.color 255,118,245,220,0         % title color
 gr.text.align 2
 gr.paint.get p_title_center
 gr.text.align 3
 gr.paint.get p_title_right
 gr.text.align 1
 gr.paint.get p_title_left

 gr.color 255,0,0,200,0
 gr.paint.get p_text
 gr.color 200,240,240,240,1
 gr.paint.get p_textbg
 gr.color 255,0,0,200,1
 gr.paint.get p_checkbox
 gr.color 255,0,0,0,1
 gr.paint.get p_tickoff
 gr.color 255,255,255,0,1
 gr.paint.get p_tickon
 gr.color 255,0,150,0,1
 gr.paint.get p_radio
 gr.color 255,0,0,0,1
 gr.paint.get p_dotoff
 gr.color 255,255,255,0,1
 gr.paint.get p_doton

 gr.color 255,100,100,100,0
 gr.set.stroke 0                % thinnest line
 gr.paint.get p_line
%--------------------
 dim lb[nrows]       % label        % object arrays
 dim sb[nrows]       % subtext
 dim tx[nrows]       % text
 dim ln[nrows]       % line
 dim ck[nrows]       % checkbox
 dim tk[nrows]       % checkbox tick
 dim rd[nrows]       % radio
 dim dt[nrows]       % radio dot
%--------------------
                                 % display rows
 for row=1 to lsize
     if row > nrows then f_n.break           % max items

     itm$ = "itm"+left$(str$(row),1)
     list.get itmtyp,row,t$        % type   e.g checkbox|text
     list.get itmlab,row,s$        % label  e.g blue    |enter name:
     list.get itmval,row,v$        % value  e.g "1"     |john

     x = indent
     y = row_height * row               % base line
     dy= y-row_height/3               % solo text y pos
     dy1 = y-row_height/2               % main text y pos
     dy2 = y-row_height/8               % sub  text y pos

     if t$="title" then p=p_title_left else p=p_label_left
     s = p_subtxt_left
     if t$ = "menu" | t$ = "title" then % position labels (only menus & titles)
        if v$ = "center" then
           x = scr_width/2
           if t$="title" then p=p_title_center else p = p_label_center
           s = p_subtxt_center
        endif
        if v$ = "right"  then
           x = scr_width-indent
           if t$="title" then p=p_title_right else p = p_label_right
           s = p_subtxt_right
        endif
     endif %_menu

     subtxt=is_in ("|",s$)              % if subtext embedded
     if (subtxt) then
        sb$ =mid$(s$,subtxt+1)          % split label,subtext
        s$=mid$(s$,1,subtxt-1)

        gr.text.draw lb[row], x,dy1,s$  % print label higher
        gr.modify lb[row],"paint",p

        gr.text.draw sb[row], x,dy2,sb$ % print subtext
        gr.modify sb[row],"paint",s
     else
        gr.text.draw lb[row], x,dy,s$   % print solo label
        gr.modify lb[row],"paint",p
     endif %_subtxt

     sw.begin t$
     sw.case "text_in"
        ov$ = v$
        while len(ov$)
              gr.text.width w,ov$
              if w >= (tx_right-tx_left-tx_height/6) then
                 ov$ = left$(ov$,len(ov$)-1)    % shorten text
              else
                 w_r.break
              endif
        repeat
                                             % text input background
        gr.rect tx[row], tx_left, y-row_height*5/6, tx_right, y-row_height/6
        gr.modify tx[row], "paint", p_textbg
                                             % text input cropped
        gr.text.draw tx[row], tx_left+tx_height/6, dy, ov$
        gr.modify tx[row], "paint", p_text

        sw.break
     sw.case "checkbox"
        gr.rect ck[row], ck_left,y-row_height*5/6, ck_right,y-row_height/6
        gr.modify ck[row], "paint", p_checkbox

        gr.rect tk[row], tk_left,y-row_height*5/6+ck_height/4,tk_right,y-row_height/6-ck_height/4
        if v$ = "0" then
           gr.modify tk[row], "paint", p_tickoff
        else
           gr.modify tk[row], "paint", p_tickon
        endif
        sw.break
     sw.case "radio"
        gr.circle rd[row], rd_x,y-row_height/2,rd_radius
        gr.modify rd[row], "paint", p_radio

        gr.circle dt[row], rd_x,y-row_height/2,rd_radius/2
        if v$ = "0" then
           gr.modify dt[row], "paint", p_dotoff
        else
           gr.modify dt[row], "paint", p_doton
        endif
        sw.break
     sw.end

     gr.line ln[row], indent,y,scr_width,y
     gr.modify ln[row], "paint", p_line

 next % ------- row

 gr.render
%--------------------   % get input and act on it

 bk_pressed=0                           % back key flag
 do
   if bk_pressed then d_u.break         % if back key pressed
   row = 0

   do                                   % wait for touch
     if bk_pressed then d_u.break       % if back key pressed

     gr.touch touched, x, y
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

   do                                   % wait till finger lifted
     gr.touch touched, a, b
   until !touched

   if y < lsize*row_height then         % which item pressed?
      row = 1+floor(y / row_height)

      list.get itmtyp,row,t$
      list.get itmlab,row,s$
      list.get itmval,row,v$

      if t$ = "menu" then d_u.break     % immediate return with row#

      sw.begin t$
      sw.case "text_in"                 % text input
         if bk_pressed then d_u.break   % must test if back key pressed here
                                        % otherwise it confuses with input

!         gr.front 0                    % (apparently uneeded)
         input s$, v$,v$                % text input dialog
!         gr.front 1                    % (apparently uneeded)
         list.replace itmval,row,v$

         ov$ = v$
         while len(ov$)
              gr.text.width w,ov$
              if (tx_right-tx_left) < w then
                 ov$ = left$(ov$,len(ov$)-1) % shorten text
              else
                 w_r.break
              endif
         repeat
         gr.modify tx[row], "text", ov$      % text replaced
         gr.modify tx[row], "paint", p_text

         sw.break
      sw.case "checkbox"
         list.get itmval,row,v$
         if v$ = "0" then v$ = "1" else v$ = "0"
         list.replace itmval,row,v$
         if v$ = "0" then
            gr.modify tk[row], "paint", p_tickoff
         else
            gr.modify tk[row], "paint", p_tickon
         endif
         sw.break
      sw.case "radio"
         for r=1 to lsize                    % look for all radios
            list.get itmtyp,r,t$
            if t$ = "radio" then
               list.get itmval,r,v$
               if r = row then v$ = "1" else v$ = "0"
               list.replace itmval,r,v$
               if v$ = "0" then
                  gr.modify dt[r],"paint",p_dotoff
               else
                  gr.modify dt[r],"paint",p_doton
               endif
            endif % radio
         next
         sw.break
      sw.end
      gr.render

   endif % row touched

 until 0

 if bk_pressed then row=0           % if back key pressed, return 0

 gr.close
 fn.rtn row
fn.end
%---------------------------------------
!following is a test, uncomment the block to use it
!!
fn_scope$ = "main"              % this is for onbackkey (see bottom)

list.create s, mytyp           % type:checkbox|text|radio|menu
list.create S, mylab           % label/question
list.create S, myval           % value (must be text)
% add types
list.add mytyp, "title",~
                "checkbox",~
                "radio",~
                "radio",~
                "text_in",~
                "menu",~        % only menu items can return
                "menu",~
                "menu"
% add labels
list.add mylab, "Settings Page",~
                "Checkbox test",~
                "Radio test",~
                "Radio test",~
                "Enter Text|Type in your name",~
                "Tap here to share|(email to your friends)",~
                "Cancel",~
                "Save"
% add values
list.add myval, "center",~
                "0"~
                "1",~
                "0",~
                "Text input test here",~
                "center",~      % val will position menu labels
                "left",~
                "right"

% the call (only menu items will return (it's row))
row = gformfill (&mytyp, &mylab, &myval)

if row = 0 then
        print "Back Key was pressed. Now in main prog"
else
        print "item ";row;" was pressed"

        list.size myval,lsize           % print all values
        for i = 1 to lsize
            list.get myval, i, v$
            print v$;"|";
        next
        print
endif
end                             % change this to 'exit' if msgs unwanted
%---------------------------------------
! Following code will trap back key and errors
! Copy and uncomment this block to your main program
OnBackKey:
                                % find out which scope the back key was pressed
        if fn_scope$ = "main" then
           print "BackKey pressed in main prog"
           % do backkey stuff for main here
           end
        endif
        if fn_scope$ = "gformfill" then
           bk_pressed = 1          % this var is inside gformfill(!) so..
           Back.resume             % ..use it to quit gracefully in do loops
        endif
        end                        % never gets to here
OnError:
        print "error: possibly back key in text input?<";fn_scope$
        end
!!
