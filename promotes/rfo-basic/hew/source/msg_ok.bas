% Msg_OK dialog < HEW framework < public domain. by humpty.drivehq.com
% v2.1
% Requires button.bas, event.bas
%---------------------------------------
                % dialog is modal and should only really be one.
                                        % split text on '|'
                                        % depends on gr.text.size
fn.def msg_ok_make (style)              % constructor

   gr.text.height fheight
   rheight = int(fheight *5/4)          % have row_height be a bit taller

   gr.bitmap.create bmp, 1,1            % bitmap for text & bg
   gr.bitmap.draw o_bmp, bmp, 0,0
   gr.modify o_bmp, "alpha", 255
   gr.hide o_bmp
!   gr.bitmap.delete bmp                 % don't need this but apk bug

                                        % button

   wg_msgbtn = button_make ("", "OK", style,0,0)
   call button ("hide","",wg_msgbtn)    % hide it

   bundle.create wg                 % create & return wg record
   bundle.put wg, "type", "msg_ok"     % record the object name and state
   bundle.put wg, "o_bmp", o_bmp
   bundle.put wg, "wg_msgbtn", wg_msgbtn
   bundle.put wg, "fheight", fheight
   bundle.put 1,"msg_ok",wg             % save myself to global bundle
 fn.rtn wg
fn.end
%---------------------------------------
fn.def msg_ok (t$)                      % callback

   bundle.get 1,"msg_ok", wg            % there is only one msg_ok
   bundle.get wg, "o_bmp", o_bmp
   bundle.get wg, "wg_msgbtn", wg_msgbtn
   bundle.get wg, "fheight", fheight

   bundle.get 1,"scr_w",scr_w             % get screen size
   bundle.get 1,"scr_h",scr_h

   gr.text.size fheight
   rheight = int(fheight *5/4)

 split m$[], t$,"\\|"                   % get text lines into array
 array.length nlines,m$[]
 if !nlines then fn.rtn

 gr.set.stroke 0
 tw = 0                                  % find max length
 for i= 1 to nlines
     gr.text.width txtw, m$[i]
     tw = max (txtw, tw)                  % max width in dots
 next

 bundle.get wg_msgbtn, "left", l
 bundle.get wg_msgbtn, "top", t
 bundle.get wg_msgbtn, "right", r
 bundle.get wg_msgbtn, "bottom", b
 bwidth = r-l                           % button width
 bheight = b-t                          % button height

 th = (nlines)*rheight+rheight/2        % height of all text + sep
 ah = th + bheight                      % height of all text, sep and button

 if tw < ah then tw=ah                  % text cannot be too slim

 pad = rheight/2
 bpad = rheight/10
 x = scr_w/2 - ceil(tw/2) - pad         % x left of box
 y = scr_h/2 - ah/2 - pad               % y top of box
 w = tw+2*pad
 h = ah+2*pad
 gr.bitmap.create bmp, w, h
 gr.bitmap.drawinto.start bmp

 call theme_color ("p_msg_border")      % outer border
 gr.rect o, 0,0, w,h

 call theme_color ("p_msg_backg")     % inner background
 gr.rect o, bpad, bpad, w-bpad,h-bpad

 gr.text.align 2
 gr.set.stroke 0
 call theme_color ("p_msg_text")
 for i= 1 to nlines
     gr.text.draw o, tw/2+pad, pad+i*rheight-rheight/4, m$[i]
 next
 gr.bitmap.drawinto.end
 gr.modify o_bmp, "bitmap", bmp
 gr.modify o_bmp, "x", x
 gr.modify o_bmp, "y", y
 gr.show o_bmp

 x$ = str$(scr_w/2-bwidth/2)                  % set button pos
 y$ = str$(y+ah+pad-bheight)
 call button ("move", x$+","+y$, wg_msgbtn)

 list.create N, msg_events              % private event list
 bundle.get 1, "widgets", main          % save the main widget list
 bundle.put 1, "widgets", msg_events    % replace it with ours
 call button ("show", "", wg_msgbtn)    % show the button & add to event list
 reply = event_get ()                   % get an event
 if reply <> 0 then call button ("flash", "", wg_msgbtn)  % if not bakkey
 call button ("hide", "", wg_msgbtn)    % hide the button
 gr.hide o_bmp                          % hide bitmap
 bundle.put 1, "widgets", main          % restore main list

 gr.bitmap.delete bmp                   % free memory
 gr.render
fn.end
%---------------------------------------
