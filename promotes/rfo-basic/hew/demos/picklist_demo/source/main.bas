% HEW picklist demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.2
                                        % include functions here
include picklist.bas
include text.bas                        % text widget
include button.bas                      % button widget
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas                      % widget colors
include event.bas                       % event loop
include init.bas                        % init screen and globals
%--------------------
gosub init_files
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "txt_h", txt_h
bundle.get 1, "widgets", widgets
%--------------------
                                        % create objects
gr.text.typeface 3                      % sans serif
gr.text.size txt_h

wg_txt = text_make ("", "text",  scr_w/3, scr_h*0.7)
wg_btn1= button_make ("", "Test1", 4, scr_w*0.1, scr_h*0.2)
wg_btn2= button_make ("C", "Test2", 4, scr_w*0.5, scr_h*0.1)
wg_btn3= button_make ("R", "Test3", 4, scr_w*0.9, scr_h*0.2)
wg_btn4= button_make ("C", "Test4", 4, scr_w*0.5, scr_h*0.3)
wg_btn5= button_make ("C", "Test5", 4, scr_w*0.5, scr_h*0.2)
wg_btn6= button_make ("R", "drop", 1, scr_w*0.5, scr_h*0.4)
wg_btn7= button_make ("R", "over", 1, scr_w*0.5, scr_h*0.6)
wg_btnE= button_make ("", "Exit", 4, scr_w*0.05, scr_h*0.6)

                                        % build event detection list
list.add widgets, wg_btn1, wg_btn2, wg_btn3, wg_btn4, wg_btn5, wg_btn6~
	wg_btn7~
	wg_btnE
gr.render                               % show objects

label$=" Pick Theme ,Default,Dark,Mint"
large$="Over Sized, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20"

gr.text.size txt_h*0.8
theme_color ("p_text")
m$="(note: other widgets will not|follow theme|until restart.)"
button_make ("note",m$,0,scr_w*0.02, scr_h*0.8)

gr.text.size txt_h*0.9              % smaller font for picklist
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$

   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg                          % execute widget callbacks
   sw.case wg_btn1                              % Test1
           rc = picklist ("left",label$)        % auto left
           sw.break
   sw.case wg_btn2                              % Test2
           rc = picklist ("top",label$)         % auto top
           sw.break
   sw.case wg_btn3                              % Test3
           rc = picklist ("right",label$)       % auto right
           sw.break
   sw.case wg_btn4                              % Test4
           rc = picklist ("bottom",label$)      % auto bottom
           sw.break
   sw.case wg_btn5                              % Test5
           rc = picklist ("",label$)            % default
           sw.break
   sw.case wg_btn6
           x = scr_w*0.51 : y=scr_h*0.4         % drop from position
           rc = picklist ("top|"+int$(x)+","+int$(y),label$)
           sw.break
   sw.case wg_btn7
           x = scr_w*0.51 : y=scr_h*0.9         % over sized list
           rc = picklist ("top|"+int$(x)+","+int$(y),large$)
           sw.break
   sw.case wg_btnE                      % exit btn pressed
           end
           sw.break
   sw.end
   gr.render
   text_do ("text","item = "+int$(rc), wg_txt)
   if rc>0 & rc<4 then gosub theme_change

until 0
end
%=======================================
% gosub code here                       % include any other gosub code here
init_files:				% copy files to sdcard
    file.exists e, "themes.ini"
    if !e then
       byte.open r, fv, "../source/themes.ini"
       if fv<>-1 then byte.copy fv,"themes.ini"
    endif
return
theme_change:
   n$ = word$(label$,rc+1,",")
   theme_set (n$)			% set new theme in theme.ini
   theme_init()                         % re-init default colors & load theme
   text_do ("text","theme = "+n$, wg_txt)
return
%=======================================
end
