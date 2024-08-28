% HEW ISR.bas < HEW framework < public domain. by humpty.drivehq.com
% v5.0
% interrupt code and code to trap back key and errors

fn.def isr_set (s$)			% set the interrupt status
       bundle.put 1,"isr$", s$
fn.end
%--------------------
fn.def bk_pressed ()			% was backkey pressed ?
  bundle.get 1,"isr$", bkey$
  if ascii(bkey$)=95 then fn.rtn 1 else fn.rtn 0
fn.end
%--------------------
goto isr_skip
OnBackKey:
			    % find out which scope the back key was pressed
			    % don't rely on local namespace
!	timer.clear
					% handle bakkey msgs here
					% if not scope defined, get from global
	bundle.get 1, "isr$", fn_scope$
!	print "OnBackKey>";fn_scope$

	bundle.put 1, "isr$", "_" 	% flag backkey pressed
	Back.resume			% just resume

OnError:
	bundle.get 1, "isr$", fn_scope$
	print "Sorry, there was an error! - aborting.."
	print "error>scope:";fn_scope$;">";GETERROR$()
	end
isr_skip:
