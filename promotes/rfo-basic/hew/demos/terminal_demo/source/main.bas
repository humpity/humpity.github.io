% HEW Terminal demo. < HEW framework < public domain. by humpty.drivehq.com
%v5.2
                                        % include functions here
include text.bas                        % text widget
include button.bas                      % button widget
include txtscroll.bas
include keyinp.bas
include ask_yn.bas
include console.bas
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas                      % widget colors
include event.bas                       % event loop
include init.bas                        % init screen and globals
%---------------------------------------
gosub init_files
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "row_h", row_h
bundle.get 1, "txt_h", txt_h
bundle.get 1, "widgets", widgets

call theme_color ("p_background")       % background
gr.rect o, 0,0,scr_w,scr_h
gr.render
                                        % create objects
gr.text.typeface 2                      % mono

gr.text.size txt_h
text_make ("C", "Hew Terminal Demo",     scr_w/2, scr_h-row_h)
gr.text.size txt_h*0.8
text_make ("", "'Stay'=keep keyboard on.",scr_w*0.025, row_h*0.5)
text_make ("", "(backkey if stuck) ",       scr_w*0.025, row_h*0.5+txt_h)

gr.text.size txt_h*0.8
conwidth = scr_w*0.95
x = (scr_w - conwidth)/2
y = txt_h*3
h = 0
gr.statusbar h                          % try to guess console & kbd height
if !h then h = scr_h/3 else h = scr_h - h*10 - y

wg_con= con_make ("", 100, x,y,conwidth,h)
con ("raw", "1", wg_con)        % set raw text mode
bundle.get wg_con, "bottom", b
b = b+txt_h*0.75                    % add buttons at bottom of console

gr.text.size txt_h
wg_btn1= button_make ("", "Stay", 4, x, b)
wg_btn2= button_make ("", "Once", 4, scr_w*0.3, b)
gr.text.size txt_h*0.9
wg_btn3= button_make ("", "clear", 4, x, b+row_h*2)
wg_btn4= button_make ("", "Eliza|Demo",4, x, scr_h-row_h*4)
wg_tog1= button_make ("R", "Turbo",1, x+conwidth, b) % right align
gr.text.size txt_h
wg_btnexit= button_make ("R", "Exit", 4, x+conwidth, scr_h-row_h*4)

                                        % build event detection list
list.add widgets, wg_con, wg_btn1, wg_btn2, wg_tog1, wg_btn3, wg_btn4, wg_btnexit

gr.text.size txt_h*0.8
gr.text.width w,"a"
maxchar = conwidth/w -1                 % approx max chars per line
gr.text.size txt_h
ask_yn_make (1)                         % the only ask_yn
keyinp_make ()
keyinp ("label", "Enter Command >")
con ("print", "Enter command, press return\n>", wg_con)
file.root rootpath$                     % <base>/data
system.OPEN                             % user shell
system.write "cd "+ rootpath$
list.create s,buff
turbo=0
gosub eliza_init
gr.render                               % show objects
%---------------------------------------
again:
do                                      % main loop
   cmd$=""
   wg= event_get ()                     % get an event

   if wg=0 then d_u.break               % bakkey pressed, end program

   bundle.get wg, "type", wtype$
   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg                    % execute widget callbacks
   sw.case wg_con                       % console touched
           call txtscroll ("touch", 0,wg) % bypass console, call txtscroll
           sw.break
   sw.case wg_btn2                      % keyboard input once only
           keyinp ("setmode", "once")
           gosub do_input
           sw.break
   sw.case wg_btn1                      % keep keyboard input on
           keyinp ("setmode", "stay")
!           con ("print", "keyboard stay on\n>", wg_con)
           do
             cmd$=""
             gosub do_input
           until rc
           sw.break
   sw.case wg_tog1                      % turbo on/off
           turbo = !turbo
           button ("set", int$(turbo), wg)
           if turbo then
            con ("print", "Turbo is ON\n>", wg_con)
           else
            con ("print", "Turbo is OFF\n>", wg_con)
           endif
           sw.break
   sw.case wg_btn3                      % clear screen
           gosub clearcmd
           sw.break
   sw.case wg_btn4                      % talk with eliza ?
           keyinp ("setmode", "stay")
           gosub eliza_intro
           do
             cmd$=""
             gosub eliza_do
           until rc
           gosub eliza_stop
           sw.break
   sw.case wg_btnexit                      % exit btn pressed
           goto really_exit
           d_u.break
   sw.end
until 0
main_exit:
rc= ask_yn ("Exit App ?")
if rc<>1 then goto again
really_exit:
kb.hide
system.close
end
%=======================================
% gosub code here                       % include any other gosub code here
% include your_code_here
include eliza.bas
%---------------------------------------
init_files:				% copy files to sdcard
    file.exists e, "themes.ini"
    if !e then
       byte.open r, fv, "../source/themes.ini"
       if fv<>-1 then byte.copy fv,"themes.ini"
    endif
return
%---------------------------------------
do_input:
        rc= keyinp ("input", &cmd$)
        if rc=1 then return                     % bakkey in once
        if rc=2 then goto closekbd_done         % bakkey in stay

        con ("tag", cmd$, wg_con)           % tag cmd to ">"
        keyinp ("put", "")
        gr.render
        if cmd$="exit" then goto closekbd
        if cmd$="clear" then goto clearcmd
        gosub shellcmd
        con ("print", ">", wg_con)
return
%---------------------------------------
closekbd:
        keyinp ("setmode", "once")      % close stay mode
        rc=2                            % make sure signal closed
closekbd_done:
!        con ("print", "keyboard stay off\n>", wg_con)
return
%---------------------------------------
clearcmd:                               % clear the console
        con ("clear", "", wg_con)
        con ("print", ">", wg_con)
return
%---------------------------------------
shellcmd:                               % do shell command cmd$
       system.write cmd$ + " 2>&1"
       pause 500
       system.READ.READY ready      % if response
       list.clear buff
       while ready
         system.READ.LINE l$
                                      % split lines with LF
         w = len(l$)
         while w > maxchar
               m$=left$(l$, maxchar)
               if turbo_mode then
                   list.add buff,m$
               else
                  con ("print", m$, wg_con)
               endif
               l$=mid$(l$,maxchar+1)
               w = len(l$)
               if bk_pressed() then w_r.break
         repeat
         system.READ.READY ready
         if turbo then
            list.add buff,l$
            if !ready then call con_bulk (buff, wg_con)
         else
            con ("print", l$, wg_con)
         endif
         if bk_pressed() then w_r.break
       repeat
       if bk_pressed() then             % restart shell on backkey
          system.close
          pause 100
          system.OPEN
          pause 100
          system.write "cd "+ rootpath$
          pause 100
          con ("print", "*break* shell restarted", wg_con)
       endif
return
%=======================================
end
