% HEW short demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.1
                                        % include functions here
include text.bas                        % text widget
include button.bas                      % button widget
%---------------------------------------
include isr.bas
include themes.bas                      % widget colors
include event.bas                       % event loop
include init.bas                        % init screen and globals
%---------------------------------------
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "widgets", widgets
bundle.get 1, "txt_h", txt_h
                                        % create objects
gr.text.typeface 3                      % sans serif
gr.text.size txt_h

wg_txt = text_make ("", "text", scr_w/3, scr_h/2)
wg_btntest= button_make ("", "Test", 4, scr_w*1/20, scr_h*3/10)
wg_btnexit= button_make ("", "Exit", 4, scr_w*1/20, scr_h*6/10)

                                        % build event detection list
list.add widgets, wg_btntest, wg_btnexit
gr.render                               % show objects
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event
   if wg=0 then end                     % bakkey pressed, end program

   bundle.get wg, "type", wtype$
   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg                          % execute widget callbacks
   sw.case wg_btntest                   % test button pressed
           call text_do ("text", "button pressed!", wg_txt)
           gr.render
       rem gosub to_your_code_here
           sw.break
   sw.case wg_btnexit                      % exit btn pressed
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
