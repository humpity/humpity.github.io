% HEW numpad_demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.1
                                        % include functions here
include numpad.bas                      % numpad widget
include button.bas                      % button widget
include text.bas                        % text widget
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas                      % widget colors
include event.bas                       % event loop
include init.bas                        % init screen and globals
%--------------------
init_hew()
bundle.get 1, "scr_w", scr_w
bundle.get 1, "scr_h", scr_h
bundle.get 1, "txt_h", txt_h
bundle.get 1, "widgets", widgets
%--------------------
                                        % create objects
gr.text.typeface 3                      % sans serif
gr.text.size txt_h

wg_txt=text_make ("","status",scr_w*0.5, scr_h*0.6)
wg_btnT1= button_make ("", "Test1", 4, scr_w*0.1, scr_h*0.1)
wg_btnT2= button_make ("C", "Test2", 4, scr_w*0.5, scr_h*0.1)
wg_btnT3= button_make ("R", "Test3", 4, scr_w*0.9, scr_h*0.1)

wg_btnExit= button_make ("", "Exit", 4, scr_w*0.05, scr_h*0.6)

                                        % event detection list
list.add widgets, wg_btnT1, wg_btnT2, wg_btnT3, wg_btnExit

gr.text.align 1                         % native basic! objects
gr.text.draw o_txt1,scr_w*0.1, scr_h*0.3, "test 1 real"
gr.text.draw o_txt2,scr_w*0.1, scr_h*0.4, "test 2 integer"
gr.text.draw o_txt3,scr_w*0.1, scr_h*0.5, "test 2 positive"
gr.render                               % show objects
num1=0 : num2=0 : num3=0
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$

   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg                          % execute widget callbacks
   sw.case wg_btnT1                     % test button 1
           rc=numpad ("",&num1)
           gr.modify o_txt1, "text", "real = "+str$(num1)+" rc="+int$(rc)
           sw.break
   sw.case wg_btnT2                     % test button 2
           rc=numpad ("dotoff",&num2)
           gr.modify o_txt2, "text", "integer = "+int$(num2)
           sw.break
   sw.case wg_btnT3                     % test button 3
           rc=numpad ("negoff",&num3)
           gr.modify o_txt3, "text", "positive = "+str$(num3)
           sw.break
   sw.case wg_btnExit                   % exit btn pressed
           end
   sw.break
   sw.end
   if !rc then stat$="OK" else stat$="cancelled"
   text_do ("text",stat$, wg_txt)
until 0
end
%=======================================
% gosub code here                       % include any other gosub code here
%=======================================
end

