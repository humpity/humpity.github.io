% HEW btimer demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.1
include button.bas                      % button widget
include btimer.bas
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas
include event.bas                       % get event
include init.bas                        % init screen, vars
%---------------------------------------
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "txt_h", txt_h
bundle.get 1, "widgets", widgets

gr.text.typeface 3                      % sans serif
gr.text.size txt_h

wg_timer = btimer_make ("",1, scr_w*1/30, scr_h*6/10)
wg_btn_reset= button_make ("", "reset", 1, scr_w*0.23, scr_h*6/10)
wg_btn_exit= button_make ("", " Exit ", 3, scr_w*1/20, scr_h*8/10)

call btimer("reset", "0:10", wg_timer)

gr.text.size txt_h
                                        % create the main detection list
list.add widgets, wg_btn_reset, wg_timer, wg_btn_exit
quit=0
gr.render                               % show objects
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event from widgets list
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$

   if wtype$="button" then call button ("flash","1",wg) % flash it

   sw.begin wg                    % execute widget callbacks
   sw.case wg_btn_reset                              % reset timer
           call btimer ("reset", "", wg_timer)
           call btimer ("flash", "2", wg_timer)
           sw.break
   sw.case wg_timer                              % start/stop timer
           if btimer ("is_running", "", wg_timer) then
              call btimer ("stop", "", wg_timer)
           else
              call btimer ("start", "", wg_timer)
           endif
           call btimer ("flash", "", wg_timer)
           sw.break
   sw.case wg_btn_exit                      % exit btn pressed
           quit=1
           sw.break
   sw.end
until quit
end
%=======================================
% gosub code here                       % include any other gosub code here
% include your_code_here
%=======================================
end
