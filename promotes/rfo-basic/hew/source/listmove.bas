% ListMove  < HEW framework < public domain. by humpty.drivehq.com
% v1.2
% Requires: button, txtscroll, custom
%---------------------------------------
					% dialog is modal
					% depends on gr.text.size
fn.def listmove_make (style)		% constructor

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

	call theme_color ("p_gen_backg")	% background
	gr.rect o, bpad, bpad, ww-bpad,wh-bpad
 gr.bitmap.drawinto.end

 gr.bitmap.draw o_bmp, bmp, wl,wt
 gr.modify o_bmp, "alpha", 255
 gr.hide o_bmp
					% create txtscroll
 tpad=int(xpad+rh/4)
 ypad=int(rh*2)
 twidth=wr-wl-rh*5-xpad
 theight=wb-wt-ypad*2
 list.create s,dummy
 ts$="S" : if style=4 then ts$+="R"	% rounded if style 4
 gr.text.size fheight*0.9		% font is smaller for txtscroll

 wg_ts= txtscroll_make (ts$, dummy, wl+tpad,wt+ypad, twidth,theight)
 txtscroll ("hide", 0, wg_ts)

 bundle.get wg_ts, "bottom", tb		% bottom of txtscroll
! tb+=int(rh/4)				% true bottom inc.border
 gr.text.size fheight			% restore font

 call theme_color ("p_gen_text")	% create title
 gr.text.align 3
 gr.text.draw o_title,wl+ww-xpad,wt+ypad*2/3,"Move Item"
 gr.hide o_title
					% create buttons
 wg_btn_q = button_make ("V", "HHHH", style,wl+tpad,(wb+tb)/2)
 button ("text", "Quit", wg_btn_q)

 wg_btn_s = button_make ("V", "HHHH", style,wl+tpad+rh*4,(wb+tb)/2)
 button ("text", "Save", wg_btn_s)

 wg_btn_d = button_make ("RB", "|HHHH", style,wr-xpad,tb)
 button ("text", "Down", wg_btn_d)
 wg_btn_u = button_make ("RB", "|HHHH", style,wr-xpad,tb-rh*3)
 button ("text", "Up", wg_btn_u)

 button ("hide","",wg_btn_u)		% hide and remove from events
 button ("hide","",wg_btn_d)
 button ("hide","",wg_btn_q)
 button ("hide","",wg_btn_s)

 bundle.create wg			% create & return wg record
 bundle.put wg, "type", "listmove"	% record the object name and state
 bundle.put wg, "left", wl
 bundle.put wg, "top", wt
 bundle.put wg, "right", wr
 bundle.put wg, "bottom", wb
 bundle.put wg, "o_bmp", o_bmp
 bundle.put wg, "o_title", o_title
 bundle.put wg, "wg_ts", wg_ts
 bundle.put wg, "wg_btn_u", wg_btn_u
 bundle.put wg, "wg_btn_d", wg_btn_d
 bundle.put wg, "wg_btn_q", wg_btn_q
 bundle.put wg, "wg_btn_s", wg_btn_s
 bundle.put wg, "fheight", fheight
 bundle.put 1, "listmove",wg            % save myself to global
 fn.rtn wg
fn.end
%---------------------------------------
fn.def listmove_title (t$)		% modify title

 bundle.get 1,"listmove",wg		% get myself from global
 bundle.get wg, "o_title", o_title
 gr.modify o_title,"text", t$

fn.end
%---------------------------------------
fn.def listmove (tlist)			% callback : return 0=quit
					% else saved and all unselected

 bundle.get 1,"listmove",wg		% get myself from global
 bundle.get wg, "o_bmp", o_bmp
 bundle.get wg, "o_title", o_title
 bundle.get wg, "wg_btn_u", wg_btn_u
 bundle.get wg, "wg_btn_d", wg_btn_d
 bundle.get wg, "wg_btn_q", wg_btn_q
 bundle.get wg, "wg_btn_s", wg_btn_s
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
 rs=i
 rows = txtscroll("getrows",0,wg_ts)
 i=i-rows+1
 if i<1 then i=1
 txtscroll("goto",i,wg_ts)		% go near

 list.create N, ask_events
 bundle.get 1, "widgets", main	% save the main widget list
 bundle.put 1, "widgets", ask_events	% replace it with ours

					% move everything to front
 display_front (o_bmp)
 display_front (o_title)
 bundle.get wg_ts, "g_all",g
 display_frontg (g)
 bundle.get wg_btn_u, "g_all",g
 display_frontg (g)
 bundle.get wg_btn_d, "g_all",g
 display_frontg (g)
 bundle.get wg_btn_q, "g_all",g
 display_frontg (g)
 bundle.get wg_btn_s, "g_all",g
 display_frontg (g)

 gr.show o_bmp			% show widgets & add to event list
 gr.show o_title
 txtscroll ("show", 0, wg_ts)
 button ("show", "", wg_btn_u)
 button ("show", "", wg_btn_d)
 button ("show","",wg_btn_q)
 button ("show","",wg_btn_s)
 quit=0
 do
   wg = event_get ()			% get an event
   if !wg then wg=wg_btn_q		% backkey
   sw.begin wg
   sw.case wg_ts
      gosub listmove_touch
      sw.break
   sw.case wg_btn_u			% up
      gosub listmove_UP
      sw.break
   sw.case wg_btn_d			% down
      gosub listmove_DN
      sw.break
   sw.case wg_btn_q			% quit
	button ("flash","",wg)
      quit=1 : rc=0
      sw.break
   sw.case wg_btn_s			% save
	button ("flash","",wg)
	gosub listmove_save
      quit=1 : rc=1
      sw.break
   sw.end
 until quit

 button ("hide", "", wg_btn_u)	% re-hide widgets
 button ("hide", "", wg_btn_d)
 button ("hide", "", wg_btn_q)
 button ("hide", "", wg_btn_s)
 txtscroll ("hide",0, wg_ts)
 gr.hide o_bmp			% hide bg
 gr.hide o_title
 bundle.put 1, "widgets", main	% restore main event list
 gr.render
 fn.rtn rc
%---------
listmove_save:
	list.get elist,rs,s$
	list.replace elist,rs,left$(s$,-2)	% remove selection
	list.clear tlist			% free memory of old list
	list.add.list tlist,elist		% replace list with changes
return
listmove_touch:
	rc = txtscroll("touch",0,wg_ts)	% pass on the touch
	if rc>0 then goto listmove_select	% if it's a tap on a row
	top = txtscroll("gettop",0,wg_ts)	% get top row
	bot = txtscroll("getbot",0,wg_ts)	% get bottom row
	if rs>=top & rs<=bot then return	% if still inside wdw
	if rs<top then rc=top else rc=bot	% force selection in wdw
listmove_select:				% unselect old row, select new row
	list.get elist,rs,s$
	list.replace elist,rs,left$(s$,-2)	% remove |V
	list.get elist,rc,s$
	list.replace elist,rc,s$+"|V"		% add |V
        txtscroll ("printrow",rs,wg)		% update txtscroll
        txtscroll ("printrow",rc,wg)
	rs=rc					% update selection
	gr.render
	return
listmove_UP:				% move item up
	t=clock()
	if rs<2 then return
	button ("set","-1",wg)		% press button
	list.get elist,rs,s1$
	list.get elist,rs-1,s2$
	list.replace elist,rs,s2$
	rs--
	list.replace elist,rs,s1$
	top = txtscroll("gettop",0,wg_ts)
	bot = txtscroll("getbot",0,wg_ts)
        txtscroll ("printrow",rs,wg_ts)
        txtscroll ("printrow",rs+1,wg_ts)
	if rs<top then
	   top = rs-(bot-top)		% mirror page up
	   if top<1 then top=1
	   txtscroll("goto",top,wg_ts)
	endif
	button ("set","-0",wg)		% release button
	while clock()-t < 200 : repeat
	gr.touch touched,x,y
	if touched then goto listmove_UP	% repeat
	return
listmove_DN:				% move item down
	list.size elist,nlines
listmove_DNR:				% repeat
	t=clock()
	if rs>=nlines then return
	button ("set","-1",wg)		% press button
	list.get elist,rs,s1$
	list.get elist,rs+1,s2$
	list.replace elist,rs,s2$
	rs++
	list.replace elist,rs,s1$
	top = txtscroll("gettop",0,wg_ts)
	bot = txtscroll("getbot",0,wg_ts)
        txtscroll ("printrow",rs,wg_ts)
        txtscroll ("printrow",rs-1,wg_ts)
	if rs>bot then
	   txtscroll("goto",rs,wg_ts)
	endif
	button ("set","-0",wg)		% release button
	while clock()-t < 200 : repeat
	gr.touch touched,x,y
	if touched then goto listmove_DNR	% repeat
	return
fn.end
%---------------------------------------
