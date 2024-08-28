% raderghost v1.0 by humpty 2015

include isr.bas			% framework
include themes.bas
!include event.bas		% don't. use custom instead.
include init.bas

include button.bas		% widgets
include picklist.bas
include pickform.bas

gosub files_init		% copy assets to SDCARD
init_hew()			% init framework & graphics

 bundle.get 1, "scale_x",scale_x
 bundle.get 1, "scale_y",scale_y
 bundle.get 1, "srows", srows
 bundle.get 1, "scr_w", scr_w
 bundle.get 1, "scr_h", scr_h
 bundle.get 1, "row_h", row_h
 bundle.get 1, "txt_h", txt_h

 FONT.LOAD font1, "ghost_theory_2.ttf"	% set font
 GR.TEXT.SETFONT font1
 theme_color("p_pf_title_fg")	% Please Wait..
 gr.text.size txt_h*1.2
 gr.set.stroke 0
 gr.text.align 2
 gr.text.draw o_wait, scr_w/2,scr_h/3,"Please Wait.."
 gr.render
 if scr_w>scr_h then rd= scr_h/2 else rd=scr_w/2	% radius
 ox= scr_w/2						% origin
 oy= scr_h/2
 foapi=0
 gr.text.size txt_h*1.1
%--------------------------------------
% debug
%~ gr.color 255,255,255,255,0
%~ gr.text.size txt_h
%~ gr.text.draw o_txt1,100,100, ""
%~ gr.text.draw o_txt2, 100,150, ""
%~ gr.text.draw o_txt3, 100,200, ""
%~ gr.render
					% post-inits
gosub about_init
gosub ghost_init
gosub radar_init
gosub menu_init
gosub set_init
include misc.bas			% misc funcs & choose sensor api
%--------------------------------------
gr.text.align 1
theme_color ("p_grid_lines")
gr.text.size txt_h*0.9
gr.text.draw o,txt_h*0.7,scr_h-txt_h*1.1, "by humpty"
theme_color("p_pf_label")
gr.text.size txt_h*1.1
gr.text.draw o,txt_h/4,txt_h*1.5, "Radar Ghost"
gr.hide o_wait
%--------------------------------------
!cymin = 2000 : cymax=3000 : speed=7
cymin = 3000 : cymax=4000 : speed=5
!cymin = 4000 : cymax=5000 : speed=3
		% s1=16k s2=8-9k s3=5k s4=4k s5=3-4k s6=3k s7=2.5k s10=1.5-2k
sweep=0
fgap=30
fadea=speed+fgap
hold=time()
do					% main loop

	gr.modify o_rotR, "angle",sweep	% move radar
	b=get_bearing()			% N wrt 12oclock -ve=anti

	Ndeg=b-90			% N wrt 3oclock -ve=anti
	if Ndeg< -180 then Ndeg+=360
	%~ gr.modify o_rotN, "angle",Ndeg	% rotate N

	gosub ghost_det			% detect ghosts
	gosub ghost_updt
	gosub ghost_blip
	gosub ghost_fade
	%~ t$="N:"+int$(Ndeg)+" S:"+int$(sweep)+" G:"+int$(nghosts)
	%~ gr.modify o_txt2, "text", t$
        gr.render
	gosub menu_chk			% menu pressed ?

	sweep+=speed
	if sweep>359 then		% check cycle time
	   sweep=0

	   cycle=time()-hold

	   if cycle > cymax & speed<10 then speed++
	   if cycle < cymin & speed>1 then speed--

	   fadea=speed+fgap

	   %~ t$="C:"+int$(cycle)+" s:"+int$(speed)
	   %~ gr.modify o_txt3, "text", t$
	   hold=time()
	endif
	if bk_pressed () then d_u.break
until 0
exit
%--------------------------------------
files_init:
	file.exists e, "themes.ini"	% this app NEEDS themes.ini
	if e then return		% OK
	byte.open r, fv, "themes.ini"	% try to get a copy from assets
	if fv=-1 then			% fatal error
	   print "aborted> Could not find themes.ini"
	   end
	endif
	byte.copy fv,"themes.ini"
return
%--------------------------------------
include ghost.bas
include radar.bas
include menu.bas
include settings.bas
include about.bas
