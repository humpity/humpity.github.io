% numpad.bas. < HEW framework < public domain. by humpty.drivehq.com
% v5.1
fn.def numpad (cmd$,num)		% callback
					% return 0=OK or 1=quit
	if ascii(cmd$)=124 then cmd$="input"+cmd$ % don't allow empty cmd
	mx$=word$ (cmd$, 2,"\\|")	% extract max width if any
	cmd$ = word$ (cmd$, 1,"\\|")
	if mx$<>"" then maxw=val(mx$) else maxw=0
	gosub numpad_init

	sw.begin cmd$
	sw.case "alloff"			% disable both
	sw.case "dotoff"
	   list.replace btns, 15, ""		% disable decimal
	sw.case "negoff"
	   if cmd$<>"dotoff" then list.replace btns, 13, "" % disable negator
	sw.break
	sw.end
!-------				% create objects
	gr.getdl dl_arr[],1		% save screen
	gosub numpad_create
	v$=using$("","%.15f",num)	% use float for rounding
					% trim trailing decimal zeroes
	if is_in(".",v$) then v$= word$(v$,1,"\\.*0+$")
	if num=0 then v$=""		% blank out any zero value
	gr.modify o_text, "text", v$+"_"
!-------				% show it and scroll it
	inc=(b-t)/8
	dec=inc * -1
	gr.show o_bmp
	for i=b to t step dec 		% scroll up
	    gr.modify o_bmp, "y", i
	    gr.render
	next i
	gr.modify o_bmp, "y", t	 % make sure we land accurately
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
	  until touched
	  if bk_pressed() then quit=1

	  x/=scale_x
	  y/=scale_y

	  if y<(t-th*2) then quit=1	% outside touched=quit
	  if x<l | x>r then quit=1
	  if quit then d_u.break
	  if y<t | x<l | x>r then d_u.continue  % ignore if not in pad
	  row = floor((y-t)/ch)
	  col = floor((x-l)/cw)
	  n = (row * 4) + col +1

	  if n<1 | n>16 then d_u.continue % illegal item
	  gosub numpad_flash
	  gosub numpad_update

	until n=-1			% OK pressed
	if quit then goto numpad_close
!-------
	if v$=""|v$="-"|v$="."|v$="-." then v$="0" % disallow weird numbers
	if val(v$)=0 then v$="0"	% disallow -ve 0
	if str$(val(v$)) = "Infinity" then
	   popup "Input Error! Number too big", 0,0, 0
	else
	   num=val(v$)			% return value
	endif
numpad_close:
	gr.hide o_text
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
fn.rtn 0				% OK
!-------
numpad_update:

  ln=len(v$)
  m=maxw-1
  if ascii(v$)=45 then m=maxw
  if ln>m & mod(n,4) & (n<>13) then return	 % overflow

  sw.begin n
  sw.case 4			% del
	if ln then v$= left$(v$, ln-1)  % delete last char
	if right$(v$,1)="E" then v$= left$(v$, ln-2)    % del exp
	sw.break
  sw.case 15			% decimal
	list.get btns, 15, s$
	if s$="" then sw.break	% disabled decimal
	if !is_in (".",v$) then v$=v$+"."
	sw.break
  sw.case 13			% negate
	list.get btns, 13, s$
	if s$="" then sw.break	% disabled negate
	if ascii(v$)=45 then v$=right$(v$,ln-1) else v$="-"+v$
	sw.break
  sw.case 8			% clr
	v$=""
	sw.break
  sw.case 12			% OK
	n=-1
	sw.break
  sw.default
	list.get btns, n,s$
	v$=v$+s$
  sw.end
  gr.modify o_text, "text",v$+"_"
  gr.render
return
!-------
numpad_flash:				% press button or flash it
	x = col*cw + l			% l
	y = row*ch + t			% t-ch
	rig = x+cw
	bot = y+ch

	if n=12|n=16 then		% btns for OK
	   x= 3*cw+l
	   y= 2*ch+t
	   bot= y+2*ch
	   n=12
	endif

	gr.modify o_flash, "left",x,"top", y,"right",rig,"bottom",bot
	list.get btns,n,s$
	gr.modify o_ftext, "x",x+cw/2, "y",y+ch*0.8, "text",s$

	gr.show o_flash
	gr.show o_ftext
	gr.render
	do
	  pause 100
	  gr.touch touched,a,a		  % wait for finger up
	until !touched
	gr.hide o_flash
	gr.hide o_ftext
	gr.render
	return
%---------------------
numpad_init:
	bundle.get 1, "scr_w",scr_w
	bundle.get 1, "scr_h",scr_h
	bundle.get 1, "txt_h",th
	bundle.get 1, "scale_x",scale_x
	bundle.get 1, "scale_y",scale_y

 list.create S,btns
 list.add btns,"1","2","3","<","4","5","6","clr","7","8","9","OK","-+","0","."," "

 gr.text.size th			% standard font height
 gr.text.width w, "0"

 bpad = th/10				% border thickness
 lpad = th/2				% line padding
 pady = th/2				% vert padding
 padx = th				% horz padding
 ch = th + pady*2			% cell height + padding
 cw = th + padx*2			% cell width
 ww = cw*4				% widget width
 wh = ch*4				% widget height

 l = (scr_w-ww)/2			% numpad rect
 b = scr_h
 t = b-wh+1
 r = l+ww       %-1

 if maxw=0 then maxw = int(ww/w)-4 	% default max chars
 if maxw > 15 then maxw=15		% restrict to 15 else 'e' shows
return %_init
%---------------------
numpad_create:
 gr.bitmap.create bmp, ww, wh		% numpad canvas
 gr.bitmap.drawinto.start bmp

 call theme_color ("p_np_border")   	% border
 gr.rect o,0,0,ww,wh
 call theme_color ("p_np_backgnd")	% background
 gr.rect o,bpad,bpad,ww-bpad,wh-bpad

 gr.set.stroke 0			% grid
 call theme_color ("p_np_border")
 for i=1 to 3
     if i=3 then w=ww-cw else w=ww-lpad
     gr.line o, lpad, i*ch, w,i*ch
     gr.line o, cw*i,lpad, cw*i,wh-lpad
 next

 call theme_color ("p_np_text")	% btn text
 gr.text.align 2			% center

 for i=0 to 15
     x = mod(i,4)*cw+cw/2
     y = floor(i/4)*ch+pady+th*0.9
     if i=11 then y=y+ch/4		% O
     list.get btns, i+1,s$
     gr.text.draw o, x, y, s$
 next

 gr.text.align 1
 gr.bitmap.drawinto.end

 gr.bitmap.draw o_bmp, bmp, l,b+1 	% move it off screen
 gr.hide o_bmp

 call theme_color ("p_np_border") 	% output text
 gr.rect o_text_bg, l,t-th*2,r,t-bpad
 gr.hide o_text_bg
 call theme_color ("p_np_backgnd")
 gr.rect o_text_bd, l+bpad,t-th*2+bpad,r-bpad,t-2*bpad
 gr.hide o_text_bd
 call theme_color ("p_np_text")
 gr.text.align 3
 gr.text.draw o_text, r-th/2, t-th*0.6, "_"
 gr.hide o_text
 call theme_color ("p_np_press_bg")  	% flasher
 gr.rect o_flash,0,0,cw,ch
 gr.hide o_flash
 call theme_color ("p_np_press_txt") 	% flash text
 gr.text.size ch*0.8
 gr.text.align 2			% center
 gr.text.draw o_ftext, 0,0,""
 gr.hide o_ftext
 gr.text.size th
return %_create
%---------------------

fn.end
%---------------------------------------
