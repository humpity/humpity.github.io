source/formfill.bas
data/formfill.css

Version 4.0

This is an on-the-fly generated html form.
Formatting relies heavily on formfill.css in the data/ directory

* call formfill (itmtyp, itmstr, itmval)
* get results from lists and return value.

Types supported:

	checkbox
	radio buttons (need at least 2)
	text
	textarea
	comment
	menu
	submit

checkbox, radios; itmval : "1"=true "0"=false
text, textarea;   itmval = input text.
menu, comment;	  itmstr = output text
submit;		  itmval = text inside the button

return: 0=bak key
	else item# of menu or submit.

Only 'submit' will save data to the lists.

First char itmstr values; 
	'~' = ignore horizontal ruler seperator.

Seperated itmstr '|' strings
	menus, comments = Will seperate to small font.
	Other = Will seperate to a command;
		command 'R' = right justify
			'C' = center

itmval values; (comment or menu only)
	'!' = jump to this item on load.
	'C' = center (and colored)

========================================================
Example Usage

include formfill.bas

list.create s, mytyp   % type:checkbox|text|textarea|radio|menu|submit|comment
list.create S, mystr   % title/question
list.create S, myval   % value (must be text)

% add types
list.add mytyp,"checkbox",~
               "text",~
               "submit"         % at least one of these or a menu to return
% add values
list.add myval, "0"~            % 0=false=unchecked, 1=true=checked
                "Some Text",~
                "Save"          % submit val displayed in button
% add titles
list.add mystr, "Checkbox test",~
                "Text test",~
                ""              % (submit titles are usually empty)
% the call
rc = formfill (mytyp, mystr, myval)

if rc = 0 then
   print "Back key pressed"
else
   list.size mytyp,last
   for i=1 to last
       list.get myval, i, val$
       print val$;"|";
   next
   print
endif
========================================================
