% menus & settings

menu_init:
					% create a button..
	wg_btnMenu= button_make ("RB", "....", 4, scr_w-txt_h, scr_h-txt_h)
return
%--------------------------------------
menu_chk:
	bundle.get wg_btnMenu, "left", ml
	bundle.get wg_btnMenu, "top", mt
	bundle.get wg_btnMenu, "right", mr
	bundle.get wg_btnMenu, "bottom", mb

	gr.bounded.touch touched,ml,mt,mr,mb	% chk if pressed
	if !touched then return
	button ("flash","",wg_btnMenu)

	old=foapi
	gosub set_get			% get settings

	if foapi <> old then		% reboot ?
	   rc=picklist ("","Reboot Now ?,yes,no")
	   if rc=1 then run "main.bas"
	endif
	%~ gr.modify o_txt1, "text", "sensi:"+int$(sensi)+" range:"+int$(range)
return
