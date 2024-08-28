% ListMark  < HEW framework < public domain. by humpty.drivehq.com
% v1.2
% Marks zero or more items in a list with "|V"
% Requires: event, button, txtscroll, custom
%---------------------------------------
				% dialog is modal
				% depends on gr.text.size
fn.def listmark_make (style)		% constructor

 bundle.get 1,"scr_w",sw		% screen
 bundle.get 1,"scr_h",sh
 ww=int(sw*0.8) : wh=int(sh*0.7)	% window
 wl=int(sw-ww)/2 : wr=wl+ww-1
 wt=int(sh-wh)/2 : wb=wt+wh-1

 gr.text.height fheight
 rh=int(fheight *6/5)		% have row height be a bit taller
 bpad=int(rh/10)
 xpad=int(rh*0.75)

 gr.bitmap.create bmp, ww,wh			% border & bg
 gr.bitmap.drawinto.start bmp
	 call theme_color ("p_gen_border")	% generic colors
	 gr.rect o, 0,0, ww,wh

	 call theme_color ("p_gen_backg")
	 gr.rect o, bpad, bpad, ww-bpad,wh-bpad
 gr.bitmap.drawinto.end
 gr.bitmap.draw o_bmp, bmp, wl,wt
 gr.modify o_bmp, "alpha", 255
 gr.hide o_bmp

 tpad=int(xpad+rh/4)				% create txtscroll
 ypad=int(rh*2)
 twidth=wr-rh*5-wl-xpad
 theight=wb-wt-rh-ypad
 list.create s,dummy
 ts$="S" : if style=4 then ts$+="R"	% rounded if style 4
 gr.text.size fheight*0.9		% font is smaller for txtscroll
 wg_ts= txtscroll_make (ts$, dummy, wl+tpad,wt+ypad, twidth,theight)
 txtscroll ("hide", 0, wg_ts)

 bundle.get wg_ts, "bottom", tb		% bottom of txtscroll
 gr.text.size fheight			% restore font

 call theme_color ("p_gen_text")	% create title
 gr.text.align 3
 gr.text.draw o_title,wl+ww-xpad,wt+ypad*2/3,"Mark Items"
 gr.hide o_title
					% create buttons
 wg_btn_o = button_make ("RB", "HHHH", style,wr-xpad,tb)
 button ("text", "OK", wg_btn_o)
 wg_btn_q = button_make ("RB", "HHHH", style,wr-xpad,tb-rh*3)
 button ("text", "Quit", wg_btn_q)
					% hide and remove from events
 button ("hide","",wg_btn_o)
 button ("hide","",wg_btn_q)

 bundle.create wg			% create & return wg record
 bundle.put wg, "type", "listmark"	% record the object name and state
 bundle.put wg, "left", wl
 bundle.put wg, "top", wt
 bundle.put wg, "right", wr
 bundle.put wg, "bottom", wb
 bundle.put wg, "o_bmp", o_bmp
 bundle.put wg, "o_title", o_title
 bundle.put wg, "wg_ts", wg_ts
 bundle.put wg, "wg_btn_o", wg_btn_o
 bundle.put wg, "wg_btn_q", wg_btn_q
 bundle.put wg, "fheight", fheight
 bundle.put 1, "listmark",wg            % save myself to global
 fn.rtn wg
fn.end
%---------------------------------------
fn.def listmark_title (t$)		% modify title

 bundle.get 1,"listmark",wg		% get myself from global
 bundle.get wg, "o_title", o_title
 gr.modify o_title,"text", t$

fn.end
%---------------------------------------
fn.def listmark (tlist)			% callback. return 0=quit else saved

 bundle.get 1,"listmark",wg		% get myself from global
 bundle.get wg, "o_bmp", o_bmp
 bundle.get wg, "o_title", o_title
 bundle.get wg, "wg_btn_o", wg_btn_o
 bundle.get wg, "wg_btn_q", wg_btn_q
 bundle.get wg, "wg_ts", wg_ts
 bundle.get wg, "fheight", fheight

 gr.text.size fheight			% restore font

 bundle.get wg_ts, "tlist", elist	% get txtscroll's elist
 list.clear elist			% free memory
 list.add.list elist,tlist		% copy caller's list

 list.size elist,sz			% goto near selection (if any)
 for i=1 to sz
	list.get elist,i,s$
	if right$(s$,2) = "|V" then f_n.break
 next i
 if i>sz then				% no previous selection ?
	i=1
	list.get elist,1,s$
	list.replace elist,1,s$+"|V"	% force one
 endif

 rows = txtscroll("getrows",0,wg_ts)
 i=i-rows+1
 if i<1 then i=1
 txtscroll("goto",i,wg_ts)

 list.create N, ask_events
 bundle.get 1, "widgets", main	% save the main widget list
 bundle.put 1, "widgets", ask_events	% replace it with ours

					% move everything to front
 display_front (o_bmp)
 display_front (o_title)
 bundle.get wg_ts, "g_all",g
 display_frontg (g)
 bundle.get wg_btn_o, "g_all",g
 display_frontg (g)
 bundle.get wg_btn_q, "g_all",g
 display_frontg (g)

 gr.show o_bmp			% show widgets & add to event list
 gr.show o_title
 txtscroll ("show", 0, wg_ts)
 button ("show", "", wg_btn_o)
 button ("show","",wg_btn_q)
 quit=0
 do
   wg = event_get ()			% get an event
   if !wg then wg=wg_btn_q		% backkey

   bundle.get wg, "type", wtype$	% get the widget type
                                      % common callback ops
   if wtype$="button" then call button ("flash","",wg) % flash it

   sw.begin wg
   sw.case wg_ts
      gosub listmark_touch
      sw.break
   sw.case wg_btn_o			% ok
      gosub listmark_OK
      quit=1 : rc=1
      sw.break
   sw.case wg_btn_q			% quit
      quit=1 : rc=0
      sw.break
   sw.end
 until quit

 button ("hide", "", wg_btn_o)	% re-hide widgets
 button ("hide", "", wg_btn_q)
 txtscroll ("hide",0, wg_ts)
 gr.hide o_bmp
 gr.hide o_title

 bundle.put 1, "widgets", main	% restore main event list
 gr.render
fn.rtn rc
%---------
listmark_touch:
	rc = txtscroll("touch",0,wg_ts)		% pass on the touch
	if rc<1 then return			% not a row

	list.get elist,rc,s$
	if right$(s$,2) = "|V" then
	   list.replace elist,rc,left$(s$,-2)	% remove |V
	else
	   list.replace elist,rc,s$+"|V"	% add |V
	endif
        txtscroll ("printrow",rc,wg)		% update row
	gr.render
	return
listmark_ok:
	list.clear tlist			% free memory
	list.add.list tlist,elist		% update caller's list
	return
fn.end
%---------------------------------------
