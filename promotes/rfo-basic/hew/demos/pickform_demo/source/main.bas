% HEW pickform demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.2
                                        % include functions here
include pickform.bas
include picklist.bas                    % only needed if picklist used in pickform
include numpad.bas                      % only needed if integer used in pickform
include text.bas                        % text widget
include button.bas                      % button widget
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas                      % widget colors
include event.bas                       % event loop
include init.bas                        % init screen and globals
%--------------------
init_hew()
bundle.get 1, "scr_w", sw
bundle.get 1, "scr_h", sh
bundle.get 1, "txt_h", th
bundle.get 1, "widgets", widgets
                                        % create objects
gr.text.typeface 3                      % sans serif
gr.text.size th

wg_txt = text_make ("C", "pickform demo",  sw*0.6, sh*0.8)

wg_btn1= button_make ("", "Test1", 4, sw*0.1, sh*0.2)
wg_btn2= button_make ("R", "Test2", 4, sw*0.9, sh*0.2)
wg_btn3= button_make ("C", "Test3", 4, sw*0.5, sh*0.05)
wg_btn4= button_make ("C", "Test4", 4, sw*0.5, sh*0.35)
wg_btn5= button_make ("C", "Test5", 4, sw*0.5, sh*0.2)
wg_btn6= button_make ("", "Full", 4, sw*0.1, sh*0.45)
wg_btn7= button_make ("", "drop", 1, sw*0.1, sh*0.05)
wg_btnE= button_make ("", "Exit", 4, sw*0.05, sh-th*3)

                                        % build event detection list
list.add widgets, wg_btn1, wg_btn2, wg_btn3, wg_btn4, wg_btn5, wg_btn6 ~
                  wg_btn7, wg_btnE

gosub init_forms
gr.text.size th
gr.render                               % show objects
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$

   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg                          % execute widget callbacks
   sw.case wg_btn1                      % test button 1 pressed
           wf = wg_form1
           rc=pickform ("input", "left",wf)
   sw.break
   sw.case wg_btn2
           wf = wg_form2
           rc=pickform ("input", "right",wf)
   sw.break
   sw.case wg_btn3
           wf = wg_form3
           rc=pickform ("input", "top",wf)
   sw.break
   sw.case wg_btn4
           wf = wg_form4
           rc=pickform ("input", "bottom",wf)
   sw.break
   sw.case wg_btn5
           wf = wg_form5
	   goto sw_bigger

   sw.case wg_btn6                              % fullscreen
           wf = wg_formfull
sw_bigger:				% larger font for subforms
           pickform ("setfont", int$(th*0.9),wg_subf1)
           pickform ("setfont", int$(th*0.9),wg_subf2)
           rc=pickform ("input", "",wf)		% no transition
           pickform ("setfont", int$(th*0.8),wg_subf1)	% set back
           pickform ("setfont", int$(th*0.8),wg_subf2)	% smaller font
   sw.break
   sw.case wg_btn7                              % drop list
           wf = wg_subf1
           pickform ("setpos", int$(sw*0.1)+","+int$(sh*0.05+1.8*th), wf)
           rc=pickform ("input", "top",wf)
   sw.break
   sw.case wg_btnE                      % exit btn pressed
           end
   sw.break
   sw.end

   if rc<0 then                         % subform pressed ?
      bundle.get wf, "subhist", s$      % get subform history chain
      text_do ("text","return chain = "+s$, wg_txt)
   else
       text_do ("text","selected item = "+int$(rc),wg_txt)
   endif
   gr.render
until 0
end
%=======================================
% gosub code here                       % include any other gosub code here
include settings.bas
%=======================================
end
