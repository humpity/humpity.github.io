% text widget. < HEW framework < public domain. by humpty.drivehq.com
% v3.2
fn.def text_make (aux$, t$, x,y)   	% constructor
					% depends on gr.text.size,typeface

 gr.text.align 1			% default is align left
 gr.text.skew 0				% default italics off
					% do embedded cmds if any
 if is_in ("C",aux$) then gr.text.align 2
 if is_in ("R",aux$) then gr.text.align 3
 if is_in ("I",aux$) then gr.text.skew -0.25

 gr.text.height h			% font height
 gr.text.width w,t$
 l = x
 t = y
 r = l+w
 b = t+h

 gr.set.stroke 0
 call theme_color ("p_text")
 gr.text.draw o_text, l,t+h*0.75, t$
 gr.paint.get p_text
 gr.set.stroke 3
 call theme_color ("p_text_highlight")
 gr.paint.get p_text_highlight

 gr.text.align 1			% restore defaults
 gr.text.skew 0
 gr.set.stroke 0

 bundle.create wg			% create & return wg record
 bundle.put wg, "type", "text"
 bundle.put wg, "left", l	  	% record the object name and state
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "o_text", o_text
 bundle.put wg, "hidden", 0
 bundle.put wg,"p_text",p_text
 bundle.put wg,"p_text_highlight",p_text_highlight

 fn.rtn wg
fn.end
%---------------------------------------
fn.def text_do (cmd$, t$, wg)		% common button callback

	bundle.get wg, "o_text", o_text
	bundle.get wg, "hidden", hidden
	bundle.get wg, "p_text", p_text
	bundle.get wg,"p_text_highlight",p_highlight

	sw.begin cmd$
	sw.case  "flash"		% flash
		gr.show o_text
		n=1
		if t$<>"" then n = val(t$) 	% flash more if t$=value
		for i=1 to n
		 gr.modify o_text,"paint",p_highlight
		 gr.render
		 pause 250			% show the flash
		 gr.modify o_text,"paint",p_text
		 gr.render
		 pause 250
		next
		if hidden then gr.hide o_text	% re-hide if it was hidden
		gr.render
		sw.break
	sw.case "text"			% change text
		gr.modify o_text, "text", t$
		sw.break
	sw.case "hide"			% hide text
		gr.hide o_text
		hidden=1
		sw.break
	sw.case "show"			% show text
		gr.show o_text
		hidden=0
		sw.break
       sw.end
       bundle.put wg, "hidden", hidden
fn.end
%---------------------------------------






