% HEW botmenu demo. < HEW framework < public domain. by humpty.drivehq.com 
%v5.0
                                        % include widget functions here
include text.bas                        % text widget
include button.bas                      % button widget
include botmenu.bas                     % bottom menu widget
%---------------------------------------
include isr.bas                         % interrupt code at end of program.
include themes.bas                      % widget colors
include event.bas                       % loop for touch events
include init.bas                        % init screen and globals
%---------------------------------------
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "txt_h", txt_h
bundle.get 1, "widgets", widgets

gr.text.typeface 3                      % sans serif
gr.text.size txt_h                  % create a txt wdiget
wg_txt = text_make ("","text", scr_w/3, scr_h/2)

                                        % create 2 buttons
wg_btn1= button_make ("", "TEST", 4, scr_w*1/20, scr_h*4/10)
wg_btn2= button_make ("", "Exit", 4, scr_w*1/20, scr_h*6/10)

list.add widgets, wg_btn1, wg_btn2      % add to detect list
                                        % create botmenu list last of all
gr.text.size txt_h*0.8
list.create s,itms
list.add itms, "Menu 1","Menu 2","Menu 3","Menu 4","Menu 5","Menu 6"
wg_botmen1 = botmenu_make (itms)

gr.render                               % show objects
%---------------------------------------
do
   wg= event_get()                      % get a touch
   if wg=0 then d_u.break               % bakkey
   bundle.get wg, "type", wg_type$
   if wg_type$="button" then call button ("flash","",wg) % flash it

   sw.begin wg
   sw.case wg_btn1                    % button1 pressed

           rc = botmenu ( wg_botmen1)
           print "botmenu returned>";rc
           call text_do ("text", str$( floor(rc) ), wg_txt)
	   gr.render
           sw.break
   sw.case wg_btn2                    % exit btn pressed
           end
           sw.break
   sw.end
until 0
end
%=======================================
% gosub code here                       % include any other gosub code here
% include your_code_here
%=======================================
end
