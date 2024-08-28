% HEW event loop demo. < HEW framework < public domain. by humpty.drivehq.com
% v5.0
%---------------------------------------
fn.def event_get ()			% detect touch events from global list
%	       - wait for touch. return widget or 0 = bakkey
%	       - copies tx,ty to wg->x, wg->y
	bundle.get 1, "evt_shell", shell % check for shell events ?
	bundle.get 1, "scale_x",scale_x % get global vars (hack)
	bundle.get 1, "scale_y",scale_y
	bundle.get 1, "widgets", widgets
	list.size widgets, wglsize
 call isr_set("")			% reset interrupt flag
 in_bg=1				% force at least 1 gr.render
 s_evt=0
 do
  do					% wait for touch
    if background()  then	   	% if app was put in bg
       in_bg=1				% set flag
       while background()
	     pause 50
       repeat
       pause 200			% try to catch bg backkey
       call isr_set("event")	 	% ignore any bg backkey
    endif
    if in_bg then		    	% if returned from bg
	gr.render		     	% redraw screen
	in_bg=0				% re-toggle bg flag
    endif
    gr.touch touched, tx, ty
    if shell then system.READ.READY s_evt
    if s_evt then d_u.break
    if bk_pressed() then d_u.break
    pause 50				% suppress cpu hack
  until touched

  if bk_pressed() then d_u.break
  if !touched & s_evt then d_u.break

  let tx = tx/scale_x			% if you don't use scaling
  let ty = ty/scale_y			% then you don't need this
  cb_found=0
  for i = 1 to wglsize			% go through widget list
      list.get widgets, i, wg
      bundle.get wg, "left", l
      bundle.get wg, "top", t
      bundle.get wg, "right", r
      bundle.get wg, "bottom", b
					% is there an object here ?
      if tx<l | tx>r | ty<t | ty>b then f_n.continue
      bundle.put wg, "x", tx		% pass the touch point
      bundle.put wg, "y", ty
      cb_found=1			% callback was found
      f_n.break
  next
  if cb_found then d_u.break
  touched=0
 until 0

 call isr_set("")			% reset interrupt flag
 if cb_found then fn.rtn wg		% detected, exit with widget
 if s_evt then fn.rtn -1		% shell event
 fn.rtn 0				% else bakkey pressed
fn.end
%---------------------------------------
fn.def event_remove (wg)		% remove a widget from the detect list

 bundle.get 1, "widgets", widgets
 list.search widgets,wg,i
 if !i then fn.rtn 0			% not there
 list.remove widgets,i
fn.end
%---------------------------------------
fn.def event_insert (wg)		% insert a widget at the head of
					% the global widget list
 bundle.get 1, "widgets", widgets
 list.search widgets,wg,i
 if i then fn.rtn 0		  	% already exists
 list.insert widgets, 1, wg
fn.end
%---------------------------------------
fn.def event_add (wg)			% insert a widget at tail of
					% the global widget list
 bundle.get 1, "widgets", widgets
 list.search widgets,wg,i
 if i then fn.rtn 0			% already exists
 list.add widgets, wg
fn.end
%---------------------------------------
fn.def event_shell (n)
   bundle.put 1, "evt_shell", n
fn.end
%---------------------------------------
