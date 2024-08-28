% text widget. < HEW framework < public domain. by humpty.drivehq.com
% v3.4 - _move
fn.def text_make (aux$, t$, x,y)   	% constructor
					% depends on gr.text.size,typeface

 x=int(x) : y=int(y)
 gr.text.align 1			% default is align left
 gr.text.skew 0				% default italics off
					% do embedded cmds if any
 if is_in ("C",aux$) then gr.text.align 2
 if is_in ("R",aux$) then gr.text.align 3
 if is_in ("I",aux$) then gr.text.skew -0.25

 gr.text.height h			% better h
 h=int(h)
 gr.get.textbounds "H",l,t,r,b		% better t
 gr.text.width w,t$
 p=t*-1					% baseline correction for plot
 s=ceil(h/3)				% border & touch sensitivity
 l=x-s : t=y-s : r=x+w+s : b=y+p+s	% make abs & add sens

 gr.set.stroke 0

 call theme_color ("p_text_bg")		% background
 gr.rect o_back, l,t,r,b
 gr.paint.get p_back

 call theme_color ("p_text")		% text
 gr.text.draw o_text, x,y+p, t$
 gr.paint.get p_text

 gr.set.stroke 3			% thicken & reverse colors for press
 gr.paint.get p_press_bg
 call theme_color ("p_text_bg")
 gr.paint.get p_press_fg

 gr.group g_all,o_text,o_back		% create the all group

 gr.text.align 1			% restore defaults
 gr.text.skew 0
 gr.set.stroke 0

 bundle.create wg			% create & return wg record
 bundle.put wg, "type", "text"
 bundle.put wg, "left", l	  	% record the object name and state
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "bord", s
 bundle.put wg, "o_text", o_text
 bundle.put wg, "o_back", o_back
 bundle.put wg,	"p_text",p_text
 bundle.put wg, "p_back", p_back
 bundle.put wg,	"p_press_fg",p_press_fg
 bundle.put wg,	"p_press_bg",p_press_bg
 bundle.put wg, "g_all", g_all
 bundle.put wg, "pressed", 0

 fn.rtn wg
fn.end
%---------------------------------------
fn.def text_do (cmd$, t$, wg)		% common button callback

	bundle.get wg, "o_text", o_text
	bundle.get wg, "o_back", o_back
	bundle.get wg, "p_text", p_text
	bundle.get wg, "p_back", p_back
	bundle.get wg, "p_press_fg",p_press_fg
	bundle.get wg, "p_press_bg",p_press_bg
	bundle.get wg, "pressed", pressed

	sw.begin cmd$
	sw.case  "flash"		% flash
		gosub text_flash
		sw.break
	sw.case "text"			% change text
		gosub text_change
		sw.break
	sw.case "hide"			% hide text
		gr.hide o_text
		gr.hide o_back
		sw.break
	sw.case "show"			% show text
		gr.show o_text
		gr.show o_back
		sw.break
	sw.case "set"			% set press value
		gosub text_set
		sw.break
       sw.end
fn.rtn 0
%---------------------
text_flash:
	if ascii(t$)=124 then t$="1"+t$	% do not allow empty+|
	d$=word$(t$,2,"\\|")			% duration d
	if is_number(d$) then d=val(d$) else d=100
	t$=word$(t$,1,"\\|")			% cycles n
	if is_number(t$) then n=val(t$) else n=1

	for i=1 to n
		if pressed then gosub text_release else gosub text_press
		do				% wait until finger lifted
		 gr.touch touched,x,y
		until !touched
		pause d
		if pressed then gosub text_press else gosub text_release
		if n>1 then pause d
	next
return
%---------------------
text_set:
	new = val(t$)			% new state
	wait = left$(t$,1)<>"-"		% wait mode
	if pressed & wait then
	   do				% wait until finger lifted
	     gr.touch touched,x,y
	   until !touched
	endif
	pressed = abs(new)		% new state
	bundle.put wg, "pressed", pressed
	if pressed then gosub text_press else gosub text_release
	if wait then
	   do				% wait until finger lifted
	     gr.touch touched,x,y
	   until !touched
	endif
return
%---------------------
text_press:				% press objects
	gr.modify o_back,"paint", p_press_bg
	gr.modify o_text,"paint", p_press_fg
	gr.render
return
%---------------------
text_release:
	gr.modify o_back,"paint", p_back
	gr.modify o_text,"paint", p_text
	gr.render
return
%---------------------
text_change:
	bundle.get wg, "bord", s	% border & sens
	gr.get.value o_text,"x",x
	gr.modify o_text, "text", t$
	gr.text.width w,o_text		% new width

	l=x-s : r=x+w+s			% make abs & add sens

	gr.modify o_back,"left",l,"right",r
	bundle.put wg, "left", l
	bundle.put wg, "right", r
return
%---------------------
fn.end	%_text_do
%---------------------------------------
fn.def text_move (x,y,wg)		% move relative x,y
isr_set ("text_move")
	bundle.get wg, "left", l
	bundle.get wg, "top",  t
	bundle.get wg, "right", r
	bundle.get wg, "bottom", b
	bundle.get wg, "g_all", g_all

	l+=x : r+=x : t+=y : b+=y
	gr.move g_all,x,y

	bundle.put wg, "left", l
	bundle.put wg, "top",  t
	bundle.put wg, "right", r
	bundle.put wg, "bottom", b
fn.end
%---------------------------------------
