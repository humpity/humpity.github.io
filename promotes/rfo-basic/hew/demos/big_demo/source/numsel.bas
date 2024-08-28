% numsel.bas. < HEW framework < public domain. by humpty.drivehq.com
% v5.0
fn.def numsel (nballs,pick$)	   	% select from 1..nballs
					% return 0=OK or 1=quit
	gosub numsel_init
!-------
	gr.getdl dl_arr[],1		% save screen
	gosub numsel_create		% create objects
!-------				% show it and scroll it
	inc=(b-t)/10
	dec=inc * -1
	gr.show o_bmp
	for i=b to t step dec		% scroll up
	    gr.modify o_bmp, "y", i
	    gr.render
	next i
	gr.modify o_bmp, "y", t		% make sure we land accurately
	gr.show o_text
	gr.show o_text_bd
	gr.show o_text_bg
	gr.render
!-------
	quit=0
	do
	  do				% wait for touch
	    if bk_pressed() then d_u.break
	    gr.touch touched, x,y
	    pause 50
	  until touched
	  if bk_pressed() then quit=1

	  x/=scale_x
	  y/=scale_y

	  if y<(t-th*2) then quit=1		% outside touched=quit
	  if x<l | x>r then quit=1
	  if quit then d_u.break
	  if y<t | x<l | x>r then d_u.continue	% ignore if not in pad
	  row = floor((y-t)/ch)
	  col = floor((x-l)/cw)
	  n = (row * 10) + col
						% ignore blank items
	  if n<1 | (n>nballs & n<nclr) then d_u.continue
	  if n>=nclr & n<nok then n=nclr	% clr btn
	  if n>=nok & n<nfin then n=nok		% ok btn

	  gosub numsel_update
	  do
	    gr.touch touched, x,y
	  until !touched
	  gr.render

	until n=nok			% OK or quit pressed

	gr.hide o_text			% close widget
	gr.hide o_text_bd
	gr.hide o_text_bg
	gr.render
	for i=t+inc to b+inc step inc	% scroll it down
	    gr.modify o_bmp, "y", i
	    gr.render
	next i
	gr.hide o_bmp
	gr.bitmap.delete bmp
	gr.newdl dl_arr[]		% restore display
	gr.render

	if quit then fn.rtn 1		% back key pressed or pressed outside
	pick$=v$		  	% update return string
fn.rtn 0				% OK
!-------
numsel_update:				% n pressed, update flags and output

	if n=nok then
	   if picked<pballs then
	      quit=1
	      s$="quit"
	   else
	      s$="OK"
	   endif
	   w=5 : nth=nok : gosub numsel_press : gr.render
	endif
	if n=nok then return

	if n=nclr then			% clear all
	   nth=nclr : s$="clr" :w=5 : gosub numsel_press : gr.render
	   gosub numsel_unpress
	   w=1
	   for i=1 to nballs
	       flags[i]=0
	       nth=i
	       list.get btns, i+1,s$
	       gosub numsel_unpress
	   next

	elseif !(picked>=pballs & !flags[n]) then	% check overflow
						% normal btn
	   flags[n] = !flags[n]			% toggle it
	   picked = picked + flags[n]*2 -1

	   w=1 : nth=n
	   list.get btns, n+1,s$
	   if flags[n] then gosub numsel_press else gosub numsel_unpress
	   gr.render
	endif

	v$=""				% build output
	picked = 0
	for i=1 to nballs
	    if flags[i] then
	       picked++
	       v$=v$+format$("##",i)
	    endif
	next
	gr.modify o_text, "text",v$

	if picked < pballs then s$="quit" else s$="OK"  % enough picked ?
	w=5 : nth=nok : gosub numsel_unpress 	% update OK/quit
return
!-------
numsel_press:				% press cell
	  theme_color ("p_np_press_bg")
	  goto numsel_print
numsel_unpress:				% unpress cell
	  theme_color ("p_np_backgnd")
numsel_print:				% print nth cell width w with s$
	  gr.bitmap.drawinto.start bmp
	  x = mod(nth,10)*cw
	  y = floor(nth/10)*ch
	  gr.rect o, x+bpad,y+2*bpad, x+w*cw-bpad,y+ch-bpad % backgnd
	  x+=w*cw/2 : y+=ypad+th
	  theme_color ("p_np_text")
	  gr.text.draw o, x, y, s$		% text
	  gr.bitmap.drawinto.end bmp
return
%---------------------
numsel_init:
	bundle.get 1, "scr_w",scr_w
	bundle.get 1, "scr_h",scr_h
	bundle.get 1, "txt_h",th
	bundle.get 1, "scale_x",scale_x
	bundle.get 1, "scale_y",scale_y

 split arr$[], trim$(pick$)		% initial selection
 array.length pballs,arr$[]		% number of balls to be picked
 dim flags[nballs]
 list.create S,btns
 list.add btns," "			% first cell is blank
 for i=1 to nballs
     list.add btns,int$(i)
     flags[i]=0
 next

 wrows = ceil((nballs+1)/10)+1		% wdw rows
 nclr= (wrows-1)*10		  	% clr btn start
 nok = nclr+5				% ok btn start
 nfin= nok+5				% btn after ok

 if scr_h < scr_w then th=scr_h/20 else th=scr_w/20   % use shortest side
 gr.text.size th
 gr.text.width w, "0"

 bpad = th/10				% border thickness
 ppad = th/5				% press padding
 lpad = th/2				% line padding
 ypad = th/2				% vert padding
 ch = th + ypad*2			% cell height + padding

 wh = ch*wrows+2*bpad			% widget height
 ww = 20*th-2*bpad			% widget width
 cw = ww /10				% cell width

 l = (scr_w-ww)/2			% numsel rect
 b = scr_h
 t = b-wh+1
 r = l+ww 	%-1

 if maxw=0 then maxw = int(ww/w)-4  	% default max chars
 if maxw > 15 then maxw=15	 	% restrict to 15 else 'e' shows
return %_init
%---------------------
numsel_create:
 gr.bitmap.create bmp, ww, wh	 	% numsel canvas
 gr.bitmap.drawinto.start bmp

 call theme_color ("p_np_border")	% border
 gr.rect o,0,0,ww,wh
 call theme_color ("p_np_backgnd") 	% background
 gr.rect o,bpad,bpad,ww-bpad,wh-bpad

 gr.set.stroke 0			% grid
 call theme_color ("p_np_border")
 for i=1 to 6
     gr.line o, lpad, bpad+i*ch, ww-lpad,bpad+i*ch	% horz
 next
 for i=1 to 9
     if i=5 then y=wh else y=wh-ch-lpad	% vert
     gr.line o, cw*i,lpad, cw*i,y
 next

 call theme_color ("p_np_text")		% btn text
 gr.text.align 2			% center

 for i=0 to nballs
     x = mod(i,10)*cw+cw/2
     y = floor(i/10)*ch+ypad+th
     list.get btns, i+1,s$
     gr.text.draw o, x, y, s$
 next
					% options at bottom
 w=5
 nth=nclr : s$="clr" : gosub numsel_unpress	% clr btn
 nth=nok  : s$="OK"   : gosub numsel_unpress 	% OK btn

 gr.text.align 1
 gr.bitmap.drawinto.end

 gr.bitmap.draw o_bmp, bmp, l,b+1 	% move it off screen
 gr.hide o_bmp

 call theme_color ("p_np_border")	% output text border
 gr.rect o_text_bg, l,t-th*2,r,t-1
 gr.hide o_text_bg
 call theme_color ("p_np_backgnd")
 gr.rect o_text_bd, l+bpad,t-th*2+bpad,r-bpad,t
 gr.hide o_text_bd
 call theme_color ("p_np_text")		% output text
 gr.text.size th*1.1
 gr.text.align 3
 gr.text.draw o_text, r-th/2, t-th*0.6, ""
 gr.hide o_text
 gr.text.align 2
 gr.text.size th

 picked = 0				% currently picked
 for p=1 to pballs
     n=val(arr$[p])			% initial selection
     gosub numsel_update		% toggle display
 next

return %_create
%---------------------

fn.end
%---------------------------------------
