% HEW dialog demo. < HEW framework < public domain. by humpty.drivehq.com
% dialog demo v5.1
                                        % include widget functions here
include text.bas                        % text widget
include button.bas                      % button widget
include msg_ok.bas                      % msg_ok dialog
include ask_yn.bas                      % ask_yn dialog
%---------------------------------------
include isr.bas
include themes.bas                      % widget colors
include event.bas                       % event loop
include init.bas                        % init screen and globals
%--------------------
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "txt_h", txt_h
bundle.get 1, "widgets", widgets

					% create objects
gr.text.typeface 3                      % sans serif
gr.text.size txt_h

wg_txt = text_make ("", "some text", scr_w/3, scr_h*3/10)
                                        % add detectables

wg_btn_2= button_make ("", "Msg OK", 1, scr_w*3/20, scr_h*5/10)

wg_btn_3= button_make ("", "Ask YN", 1, scr_w*11/20, scr_h*5/10)

wg_btn_exit= button_make ("", "Exit", 3, scr_w*1/20, scr_h*8/10)

                                        % modals last of all
wg_msg_ok = msg_ok_make (1)             % the only msg_OK
wg_ask_yn = ask_yn_make (1)             % the only ask_yn

                                        % the main detection list
list.add widgets, wg_btn_2, wg_btn_3, wg_btn_exit
gr.render                               % show objects
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event from widgets list
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$

   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg                    % execute widget callbacks
   sw.case wg_btn_2                              % msg ok demo
           call msg_ok ("Test OK Message|here")
           call text_do ("text", "OK", wg_txt)
           gr.render
           sw.break
   sw.case wg_btn_3                              % ask yn demo
           rc= ask_yn ("Having a good|time ?")
           if !rc then call text_do ("text", "sorry i asked!", wg_txt)
           if rc=1 then call text_do ("text", "thought so", wg_txt)
           if rc=2 then call text_do ("text", "never mind", wg_txt)
           gr.render
           sw.break
   sw.case wg_btn_exit                      % exit btn pressed
           exit
           sw.break
   sw.end
until 0					% do forever
end
%=======================================
% gosub code here                       % include any other gosub code here
% include your_code_here

%=======================================
end
