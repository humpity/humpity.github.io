% Ask_YN dialog  < HEW framework < public domain. by humpty.drivehq.com
% v2.0
% Requires button.bas, event.bas
%---------------------------------------
                        % dialog is modal and should only really be one.
                                        % depends on gr.text.size
fn.def ask_yn_make (style)              % constructor

   gr.text.height fheight
   rheight = int(fheight *5/4)          % have row_height be a bit taller

   gr.bitmap.create bmp, 1,1            % bitmap for text & bg
   gr.bitmap.draw o_bmp, bmp, 0,0
   gr.modify o_bmp, "alpha", 255
   gr.hide o_bmp
!   gr.bitmap.delete bmp                 % don't need this but apk bug

                                        % button
   wg_askbtn_y = button_make ("", "yes", style,0,0)
   wg_askbtn_n = button_make ("", "___", style,0,0)
   call button ("text", "no", wg_askbtn_n)
   call button ("hide","",wg_askbtn_y)  % hide and remove from list
   call button ("hide","",wg_askbtn_n)

   bundle.create wg                 % create & return wg record
   bundle.put wg, "type", "ask_yn"    % record the object name and state
   bundle.put wg, "o_bmp", o_bmp
   bundle.put wg, "wg_askbtn_y", wg_askbtn_y
   bundle.put wg, "wg_askbtn_n", wg_askbtn_n
   bundle.put wg, "fheight", fheight
   bundle.put 1, "ask_yn",wg            % save myself to global
 fn.rtn wg
fn.end
%---------------------------------------
fn.def ask_yn (t$)                      % callback. return 0=bakkey 1=yes 2=no

   bundle.get 1,"ask_yn",wg             % get myself from global
   bundle.get wg, "o_bmp", o_bmp
   bundle.get wg, "wg_askbtn_y", wg_askbtn_y
   bundle.get wg, "wg_askbtn_n", wg_askbtn_n
   bundle.get wg, "fheight", fheight

   bundle.get 1,"scr_w",scr_w             % get screen size
   bundle.get 1,"scr_h",scr_h

   gr.text.size fheight
   rheight = int(fheight *5/4)          % have row_height be a bit taller

   split m$[], t$,"\\|"                   % get text lines into array
   array.length nlines,m$[]
   if !nlines then fn.rtn

   gr.set.stroke 0
   tw = 0                                  % find max length
   for i= 1 to nlines
       gr.text.width txtw, m$[i]
       tw = max (txtw, tw)                  % max width in dots
   next

   bundle.get wg_askbtn_y, "left", l
   bundle.get wg_askbtn_y, "top", t
   bundle.get wg_askbtn_y, "right", r
   bundle.get wg_askbtn_y, "bottom", b
   bwidth = r-l                           % button width of "yes"
   bheight = b-t                          % button height

   th = nlines*rheight+rheight/2          % height of all text + sep
   ah = th + bheight                      % height of all text, sep and button

   if tw < ah then tw=ah                  % text cannot be too slim
   if tw < 3*bwidth then tw=3*bwidth

   pad = rheight/2
   bpad = rheight/10
   x = scr_w/2 - ceil(tw/2) - pad        % x left of box
   y = scr_h/2 - ah/2 - pad              % y top of box
   w = tw+2*pad
   h = ah+2*pad

   gr.bitmap.create bmp, w, h
   gr.bitmap.drawinto.start bmp

   call theme_color ("p_ask_border")   % outer border
   gr.rect o, 0,0, w,h

   call theme_color ("p_ask_backgnd")
   gr.rect o, bpad, bpad, w-bpad,h-bpad

   gr.text.align 2
   gr.set.stroke 0
   gr.text.size fheight
   call theme_color ("p_ask_text")
   for i= 1 to nlines
     gr.text.draw o, tw/2+pad, pad+i*rheight-rheight/4, m$[i]
   next
   gr.bitmap.drawinto.end
   gr.modify o_bmp, "bitmap", bmp
   gr.modify o_bmp, "x", x
   gr.modify o_bmp, "y", y
   gr.show o_bmp

   x$ = str$(scr_w/2-bwidth*1.5)                  % set button positions
   y$ = str$(y+ah+pad-bheight)
   call button ("move", x$+","+y$, wg_askbtn_y)
   x$ = str$(scr_w/2+bwidth*0.5)                  % no button
   call button ("move", x$+","+y$, wg_askbtn_n)

   list.create N, ask_events
   bundle.get 1, "widgets", main          % save the main widget list
   bundle.put 1, "widgets", ask_events    % replace it with ours
   call button ("show", "", wg_askbtn_y)    % show the button & add to event list
   call button ("show", "", wg_askbtn_n)

   reply = event_get ()                   % get an event
   sw.begin reply
   sw.case wg_askbtn_y
      call button ("flash", "", wg_askbtn_y)  % if not bakkey
      rc=1
      sw.break
   sw.case wg_askbtn_n
      call button ("flash", "", wg_askbtn_n)
      rc=2
      sw.break
   sw.default
      rc=0
   sw.end
   call button ("hide", "", wg_askbtn_y)    % hide the buttons
   call button ("hide", "", wg_askbtn_n)
   gr.hide o_bmp                          % hide bitmap

   bundle.put 1, "widgets", main          % restore main list

   gr.bitmap.delete bmp                   % free memory
   gr.render
 fn.rtn rc
fn.end
%---------------------------------------
