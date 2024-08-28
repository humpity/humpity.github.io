%
set_init:		       		% init settings

fn.def set_find (labels, key$)	  	% find a key in a label list
					% return the index or 0=fail
	found=0
	list.size labels,n		% find label match
	for i=1 to n
	    list.get labels, i, l$
	    l$ = word$(l$,1,"\\|")	% ignore sub text
	    l$ = replace$ (l$, " ", "_") % convert spaces to underscore
	    if lower$(l$)<>lower$(key$) then f_n.continue
	    found=i
	    f_n.break
	next
fn.rtn found
fn.end
%-------------------------------------- % Defaults Form
list.create s, setR_typ	 % type
list.create s, setR_lab	 % label/question
list.create s, setR_val	 % value (must be a text string)
list.add setR_typ~
		"title"~
		"menu"~			% reset confirm
		"menu"			% reset quit
list.add setR_lab~
		"Confirm"~
		"Yes"~
		"No"
list.add setR_val~
		"C"~
		""~
		""
wg_formR= pickform_make (-1,-1,-1,-1, setR_typ, setR_lab, setR_val)
%-------------------------------------- % Settings Form
list.create s, setS_typ	 	% type
list.create s, setS_lab	 	% label/question
list.create s, setS_val	 	% value (must be a text string)

list.create s, defS_val		% default values

senslist$="choose,low,medium,high"
ranglist$="choose,near,normal,far"
list.add setS_typ~
		"title"~
		"picklist|"+senslist$~	% sensitivity
		"picklist|"+ranglist$ ~	% range
		"checkbox"~		% grid
		"checkbox"~		% force old api
		"subform|"+int$(wg_formR)	% reset form
list.add setS_lab~
		"Settings"~
		"Sense"~		% sensitivity
		"Range"~		% range
		"Grid"~			% grid
		"Force Old API|needs reboot"~	% force old api
		"Defaults"	% reset
list.add defS_val~
		"C"~
		"high"~			% sensitivity
		"normal"~		% range
		"1"~			% grid
		"0"~			% force old api
		"C"			% reset form
%-------------------------------------- % load default values
list.add.list setS_val, defS_val
%-------------------------------------- % Instantiate
	wg_formS= pickform_make (-2 , -1 , -1, -1, setS_typ, setS_lab, setS_val)

	pickopt$="Menu,  Settings ,About,Exit"

	gosub set_load			% load from file
	gosub set_updg			% update globals
return %_set_init
%--------------------------------------
set_get:				% get settings from user

	rc=picklist ("bottom",pickopt$) % main menu

	if rc<1 then return		% quit
	sw.begin rc
	sw.case 1			% settings
	   r=pickform ("input","left",wg_formS)
	   if r=-1 then			% subform ?
	      bundle.get wg_formS, "subhist", sub$	% get history
	      if sub$="6,2" then	% reset values
		 list.clear setS_val
		 list.add.list setS_val, defS_val
		 msg_out ("settings reset")
	      endif
	   endif
	   gosub set_save		% save settings
	   gosub set_updg		% update globals
	sw.break
	sw.case 2			% about
	   gosub about_get
	sw.break
	sw.case 3			% exit
	   exit
	sw.end
return %_set_get
%--------------------------------------
set_updg:				% update globals
	list.size setS_lab,n
	for i=1 to n
	    list.get setS_lab, i, l$
	    l$ = word$(l$,1,"\\|")
	    list.get setS_val, i, v$

	    if l$="Sense"	then
		if v$="low" then sensi=30
		if v$="medium" then sensi=26
		if v$="high" then sensi=15
	    endif
	    if l$="Range" then
		if v$="near" then range=31
		if v$="normal" then range=40
		if v$="far" then range=51
	    endif
	    if l$="Grid" then gridon=val(v$)
	    if l$="Force Old API" then foapi=val(v$)
	next

	if gridon then
	   gr.modify o_grid,"alpha",255
	else
	   gr.modify o_grid,"alpha",0
	endif
return
%--------------------------------------
set_load:			       	% load settings
	file.exists rc, "settings.ini"
	if !rc then goto set_save	% if no file, then create one
	file.size rc, "settings.ini"
	if !rc then goto set_save	% if empty file, then overwrite it

	text.open r,fv,"settings.ini"
	if fv = -1 then msg_out ("!file open error!")
	if fv = -1 then return
	do
	  text.readln fv,s$
	  if s$="EOF" then d_u.break
	  eq = is_in ("=",s$)
	  if !eq then d_u.continue
	  n$ = word$(left$(s$, eq-1),1)	 % key
	  v$ = word$(mid$ (s$, eq+1),1)	 % value
	  n$ = lower$(n$)

	  i = set_find (setS_lab, n$)		   	% find keyword
	  if i then list.replace setS_val, i, v$	% update value
	until 0
	text.close fv
return %_set_load
%--------------------------------------
set_save:			       % save settings to file

	file.delete ignore, "settings.ini"
	text.open w,fv,"settings.ini"

	list.size setS_lab,n		% find values to write
	for i=1 to n
	    list.get setS_typ, i, t$
	    t$ = word$(t$,1,"\\|")	% get type
	    if is_in(t$,"title,label,menu,subform") then f_n.continue
	    list.get setS_val, i, v$
	    list.get setS_lab, i, l$
	    l$ = word$(l$,1,"\\|")
	    l$= replace$ (l$, " ", "_")
	    text.writeln fv, l$+" = "+v$
	next

	text.close fv
return %_set_save

