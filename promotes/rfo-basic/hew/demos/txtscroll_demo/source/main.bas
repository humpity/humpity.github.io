% HEW short demo. < HEW framework < public domain. by humpty.drivehq.com
% txtscroll demo v6.0
                                        % include widget functions here
include text.bas                        % text widget
include button.bas                      % button widget
include txtscroll.bas
%---------------------------------------
include isr.bas                         % interrupt handlers
include themes.bas                      % colors
include event.bas                       % event loop functions
include init.bas                        % init screen and globals, start run
%--------------------
init_hew()
bundle.get 1, "scr_w", sw
bundle.get 1, "scr_h", sh
bundle.get 1, "txt_h", th
bundle.get 1, "row_h", rh
bundle.get 1, "widgets", widgets
%---------------------------------------
gr.text.typeface 3                      % create objects
gr.text.size th
					% detectables

wg_btn_hide = button_make ("", "Show", 1, sw*0.55, rh*2)
	      button ("text","Hide",wg_btn_hide)
wg_btn_roll = button_make ("", " Roll ", 4, sw*0.55, rh*4)

wg_btn_dn = button_make ("B", "+10", 1, sw/20, sh*0.95)
wg_btn_up = button_make ("B", "-10", 1, sw*5/20, sh*0.95)
wg_btn_exit = button_make ("B", "Full & Exit", 3, sw*10/20, sh*0.95)

list.create s,tlist
list.add tlist, "Centered|C"
list.add tlist, "Right Justified|R"
list.add tlist, "Italicized|I"
list.add tlist, "Color2|2"
list.add tlist, "Color3 centered|3C"
list.add tlist, "Initially Reversed|V"
rs=6					% reverse is the selected row
for i=7 to 100
    list.add tlist, int$(i)+" Swipe Me"
next
gr.text.align 1

gr.text.size th*0.85
wg_lb1= text_make ("I", "Normal List", sw/20,sh*0.08-th*0.85)
wg_ts1= txtscroll_make ("", tlist, sw/20,sh*0.08, sw*0.45,sh*0.5)

gr.text.size th*0.85
wg_lb2= text_make ("I", "Raw List (synced)", sw/20,sh*0.62-th*0.85)
wg_ts2= txtscroll_make ("WR", tlist, sw/20,sh*0.62, sw*0.8,sh*0.2)

                                        % callback detect list
list.add widgets, wg_ts1, wg_ts2, wg_btn_dn, wg_btn_up ~
                  wg_btn_hide, wg_btn_roll, wg_btn_exit
%-------------------------              % non-detectables
gr.text.size th*0.8
wg_txt = text_make ("", "BakKey to quit", sw*0.55, sh*0.03)
gr.render
%-------------------------
hidden=0
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "type", wtype$	% get the widget type
                                        % common callback ops
   if wtype$="txtscroll" then gosub touch
   if wtype$="button" then call button ("flash","",wg) 		% flash buttons

   sw.begin wg				% specific ops
   sw.case wg_btn_dn
           lines = -10                  % move dn = scroll up
           gosub scroll			% do remote scroll
           sw.break
   sw.case wg_btn_up
           lines = 10                   % move up = scroll dn
           gosub scroll
           sw.break
   sw.case wg_btn_hide			% hide or show it
           if !hidden then
	      txtscroll ("hide", 0, wg_ts1)
	      button ("set","1",wg_btn_hide)	% toggle button
	      button ("text","Show",wg_btn_hide)
	   else
	      txtscroll ("show", 0, wg_ts1)
	      button ("set","0",wg_btn_hide)
	      button ("text","Hide",wg_btn_hide)
	   endif
	   hidden=!hidden
           sw.break
   sw.case wg_btn_roll			% roll to 1st page on widget 1
	   gosub roll
           sw.break
   sw.case wg_btn_exit                  % full screen demo & exit
           gosub fullexit
           sw.break
   sw.end
until 0					% do forever
end
%=======================================
% gosub code here
touch:
	rc = txtscroll("touch",0,wg)	% pass on the touch to the widget
	if wg=wg_ts3 then return	% ignore furthur processing if fullscreen

        call text_do ("text", int$(rc), wg_txt)  % print return code
	if rc>0 then goto tap		% if it's a tap
	goto sync			% sync other widget
tap:					% unselect old row, select new row
	list.get tlist,rs,s$
	list.replace tlist,rs,left$(s$,-2)	% remove |V
	list.get tlist,rc,s$
	list.replace tlist,rc,s$+"|V"		% add |V

        txtscroll ("printrow",rs,wg_ts1)	% update both widgets
        txtscroll ("printrow",rc,wg_ts1)
        txtscroll ("printrow",rs,wg_ts2)
        txtscroll ("printrow",rc,wg_ts2)
	gr.render
	rs=rc
        return
roll:					% roll to 1st page on widget 1
	wg=wg_ts1
        txtscroll ("roll", 1, wg)
	button ("set","0",wg_btn_hide)	% unset the hide button
	button ("text","Hide",wg_btn_hide)
	hidden=0
	goto sync			% sync other widget
scroll:					% remote scroll widget 1
	wg=wg_ts1
        rc = txtscroll("scroll",lines, wg)  % remote scroll
sync:					% sync other widget
	top = txtscroll("gettop",0,wg)	% get the top row
	if wg=wg_ts1 then wg=wg_ts2 else wg=wg_ts1
	call txtscroll("goto",top,wg)
	return
fullexit:                               % full scr demo, then exit
        gr.cls                          % trash the display!
        list.clear widgets              % trash the callback list !
                                        % create fullscr txtscroll
        gr.text.size th*0.85     % with "N"o border
        wg_ts3= txtscroll_make ("N", tlist, 0,0, sw,sh)
        gr.render
        list.add widgets, wg_ts3        % the only widget there !
        return                          % bakkey will force exit
%=======================================
end
