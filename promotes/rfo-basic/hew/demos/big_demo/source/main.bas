% big demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.1
                                        % include widget functions here
include text.bas                        % text widget
include button.bas                      % button widget
include msg_ok.bas                      % msg_ok dialog
include ask_yn.bas                      % ask_yn dialog
include progress.bas                    % progress bar
include btimer.bas                      % timer
include botmenu.bas                     % bottom menu
include numpad.bas                      % numeric keypad
include numsel.bas                      % numeric selector
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas                      % widget colors
include event.bas                       % get event
include init.bas                        % init screen, vars
%---------------------------------------
init_hew()
bundle.get 1, "scr_w", sw
bundle.get 1, "scr_h", sh
bundle.get 1, "txt_h", th
bundle.get 1, "row_h", rh
bundle.get 1, "widgets", widgets

gr.text.typeface 3                      % sans serif
gr.text.size th

wg_txt1 = text_make ("", "Please wait..", sw*1/30, sh*3.5/10)
gr.render
wg_txt2 = text_make ("", "Timer",  sw*1/30, sh*0.52)

gr.text.size th*0.9
wg_btn1= button_make ("", "|hide|this|  button ! ", 4,  sw/3, sh*0.06)
wg_btnset= button_make ("", "is Unset", 1,  sw*1/30, sh*0.20)

wg_btn2= button_make ("", "Msg OK", 2, sw*0.28, sh*0.45)
wg_btn3= button_make ("", "Ask YN", 2, sw*0.65, sh*0.45)
wg_btn4= button_make ("", "  move  |it", 1, sw*20/30, sh*0.6)
wg_btn5= button_make ("|button", "BotMenu",5, sw*1/30, sh*0.73)
theme_color ("p_btn_press_bg")
w$=str$(sw/3)
wg_btn7= button_make ("B~"+w$, "|one", 1,  0, sh)
wg_btn8= button_make ("B~"+w$, "|numpad", 1,  sw/3, sh)
wg_btn9= button_make ("B~"+w$, "|numsel", 1,  sw*2/3, sh)

gr.text.size th
bundle.get wg_btn8,"top",t
wg_btnexit= button_make ("BC", "Exit", 4, sw/2, t-th/5)
wg_prg_1 = progress_make ()
wg_timer = btimer_make ("",1, sw*1/30, sh*6/10)
wg_link = button_make ("","link",0, sw*0.45, sh*6/10)  % borderless btn
wg_btn6= button_make ("", "reset", 1, sw*0.23, sh*6/10)

btimer("reset", "0:10", wg_timer)
                                        % create botmenu list
gr.text.size th*0.8
list.create s,itms
list.add itms, "Menu 1","Menu 2","Menu 3","Menu 4","Menu 5","Menu 6"
wg_botmen1 = botmenu_make (itms)
                                        % create modals last of all
gr.text.size th
wg_msg_ok = msg_ok_make (2)             % the only msg_OK
wg_ask_yn = ask_yn_make (3)             % the only ask_yn
gr.text.size th
                                        % create the main detection list
list.add widgets, wg_btnexit ~          % detect exit first
                  wg_btnset, wg_btn2, wg_btn3, wg_btn4, wg_btn1 ~
                  wg_btn5, wg_btn6, wg_btn7, wg_btn8, wg_btn9 ~
                  wg_timer, wg_link
check=0
quit=0
text_do ("text", "", wg_txt1)
gr.render                               % show objects
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event from widgets list
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$
   if wtype$="button" then button ("flash","1",wg) % flash it

   sw.begin wg                          % execute widget callbacks
   sw.case wg_btn4                      % move
           gosub move_button
           sw.break
   sw.case wg_btn2                              % msg ok demo
           msg_ok ("Test OK Message|here")
           text_do ("text", "OK", wg_txt1)
           gr.render
           sw.break
   sw.case wg_btn3                              % ask yn demo
           rc= ask_yn ("Having a good|time ?|Is everything|All|Right?")
           if !rc then text_do ("text", "sorry i asked!", wg_txt1)
           if rc=1 then text_do ("text", "thought so", wg_txt1)
           if rc=2 then text_do ("text", "never mind", wg_txt1)
           gr.render
           sw.break
   sw.case wg_btn1                              % hide no-border button
           button ("flash", "", wg_btn1)
           button ("hide", "", wg_btn1)
           text_do ("text", "hidden", wg_txt1)
           gr.render
           sw.break
   sw.case wg_btn5
           rc = botmenu ( wg_botmen1)
           text_do ("text", str$( floor(rc) ), wg_txt1)
           gr.render
           sw.break
   sw.case wg_btn6                              % reset timer
           btimer ("reset", "", wg_timer)
           btimer ("flash", "", wg_timer)
           text_do ("text", "timer reset", wg_txt1)
           sw.break
   sw.case wg_btnset                            % set or unset btn
           check = !check
           if check then c$="is Set" else c$="is UnSet"
           button ("text", c$, wg_btnset)
           button ("set", int$(check), wg_btnset)
           sw.break
   sw.case wg_timer                              % start/stop timer
           if btimer ("is_running", "", wg_timer) then
              btimer ("stop", "", wg_timer)
              text_do ("text", "timer stopped", wg_txt1)
           else
              btimer ("start", "", wg_timer)
              text_do ("text", "timer started", wg_txt1)
           endif
!           btimer ("flash", "", wg_timer)
           sw.break
   sw.case wg_link
           text_do ("text", "button type 0 pressed", wg_txt1)
           text_do ("flash", "2", wg_txt1)
           sw.break
   sw.case wg_btn7
           text_do ("text", "experimental width override", wg_txt1)
           text_do ("flash", "2", wg_txt1)
           sw.break
   sw.case wg_btn8
           num=0
           numpad ("",&num)
           text_do ("text", "numpad:"+str$(num), wg_txt1)
           sw.break
   sw.case wg_btn9
           p$ = "1 2 3 4 5 6"
           numsel (49, &p$)
           n=0
           text_do ("text", "numsel:"+p$, wg_txt1)
           sw.break
   sw.case wg_btnexit                      % exit btn pressed
           quit=1
           sw.break
   sw.end
until quit
end
%=======================================
% gosub code here                       % include any other gosub code here
% include your_code_here
move_button:
           progress ("show", 0 ,wg_prg_1)
           bundle.get wg_btnset,"right",r
           if r+10 > sw then button ("move", "0,-0", wg_btnset)
           for i=1 to 10
               button ("move", "+10,+0", wg_btnset)
               progress ("set", i/10 ,wg_prg_1)
               gr.render
               pause 20
           next
           text_do ("text", "moved!", wg_txt1)
           progress ("hide", 0 ,wg_prg_1)
           gr.render
return
%=======================================
end
