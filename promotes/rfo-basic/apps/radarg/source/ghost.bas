% ghosts module

ghost_init:

	sensi=26	% thresh_lwr = sensitivity 26=norm 15=high=more sensitive
	range=40	% thresh_upr = range 51=far 40=med
	siz=rd/5
	gr.bitmap.load bmp, "ghost.png"
	gr.bitmap.scale b_gho, bmp, siz, siz,0
	gr.bitmap.delete bmp
	list.create n,ghosts
	nghosts=0
	life=30
	fdec=3
return
%--------------------------------------
ghost_add:		% add dis,ang -180..180 relative to 3oclock +ve=anti
	bundle.create g
	dur=life
	now=dur+fdec

	a=ang+get_bearing()-90		% must rotate with N
	x=ox+cos(toradians(a))*dis
	y=oy+sin(toradians(a))*dis


	%~ gr.color 0,255,255,255,0
	%~ gr.circle o, x, y, siz/2
	gr.bitmap.draw o, b_gho, x,y
	movef2b()			% move it to back
	gr.hide o
	bundle.put g, "obj",o
	bundle.put g, "dur",dur
	bundle.put g, "now",now
	bundle.put g, "ang",ang		% relative to 3oclock +ve=anti
	bundle.put g, "dis",dis
	list.add ghosts,g : nghosts++
	%~ gr.modify o_txt3, "text", "added. ang:"+int$(ang)+" dis:"+int$(dis)

return
%--------------------------------------
ghost_del:				% remove g,i
	bundle.get g, "obj",o
	bundle.clear g
	list.remove ghosts,i
	nghosts--
	gr.hide o
	Gr.getDL disp[]			% remove hidden
	Gr.newDL disp[]
	undim disp[]
	%~ gr.modify o_txt3, "text", "deleted. remain:"+int$(nghosts)
return
%--------------------------------------
ghost_det:				% detect
	if sweep then return		% only at top
	if nghosts >4  then return

	%~ gr.modify o_txt1, "text", ""
	gosub ghost_detect		% dis,ang from N -ve anti
	if dis>rd then return		% too weak
	%~ gr.modify o_txt1, "text", "detected S:"+int$(strength)+" A:"+int$(ang)+" :D"+int$(dis)
	%~ audio.stop
	%~ audio.play ding

!dis=rd
	if dis<siz/2 then dis=siz/2	% don't allow dead centre
	if dis>rd then dis=rd % don't allow outside

	new=1
	for i=nghosts to 1 step -1		% chk if old ghost
	 list.get ghosts,i,g
	 bundle.get g, "ang",a
	 bundle.get g, "dis",d

	 da=40*(rd-dis)/rd+10
	 if ang<a-da | ang>a+da then f_n.continue	% new
	 if dis<d-siz | dis>d+siz then f_n.continue	% new
					% it's an old one
	 %~ gr.modify o_txt1, "text", "refreshed S:"+int$(strength)+" A:"+int$(ang)+" :D"+int$(dis)
	 bundle.get g,"dur",dur
	 dur=life			% revitalise
	 bundle.put g,"dur",dur
	 bundle.put g,"ang",ang
	 bundle.put g,"dis",dis
	 new=0
	 f_n.break
	next

	if new then gosub ghost_add	% new ghost ?
return
%-------------------
ghost_blip:
	for i=nghosts to 1 step -1	% process new ghost first
	 list.get ghosts,i,g
	 bundle.get g,"ang",a
	 bundle.get g, "dur",dur
	 bundle.get g, "now",now
         bundle.get g, "obj",o

	 a+=Ndeg			% visual follow
	 if a<0 then a+=360
	 if a<sweep | a>=sweep+speed then f_n.continue % out of range

	 if dur<=0 then gosub ghost_del		% remove expired ghosts
	 if dur<=0 then f_n.continue
					% blip
	 %~ gr.modify o_txt3, "text", "a="+int$(a)+" w="+int$(sweep)+" n="+int$(now)+" d="+int$(dur)
	 if dur=life then gr.show o	% birth or refresh
	 now=dur
	 alpha = now/life * 255
	 gr.modify o, "alpha",alpha

	 dur-=fdec*2			% diminish life
	 bundle.put g, "dur",dur
	 bundle.put g, "now",now

	next
return
%--------------------------------------
ghost_fade:				% fade ghosts

	if sweep < fadea then return	% only after fade angle
	fadea=sweep+speed+fgap		% next fade

	for i=1 to nghosts
	 list.get ghosts,i,g
	 bundle.get g, "dur",dur
	 bundle.get g, "now",now
         bundle.get g, "obj",o

	 now -= fdec			% fade
	 if now<0 then now=0
	 alpha = now/life * 255
	 if alpha < 50 then alpha=50	% hold last fade
	 gr.modify o, "alpha",alpha

	 %~ if ++frm=frms then frm=1
	 %~ gr.modify o, "bitmap", gframe[frm]

	 bundle.put g, "now",now
	next
return
%--------------------------------------
ghost_updt:				% update ghost location
	for i=1 to nghosts
	 list.get ghosts,i,g

	 bundle.get g, "dis",d
	 bundle.get g, "ang",a
	 bundle.get g, "obj",o

	 a+=get_bearing()-90		% must rotate with N
	 x=ox+cos(toradians(a))*d
	 y=oy+sin(toradians(a))*d	% add from 3oclock clockwise going down

	 xb = abs(cos(toradians(a))*rd)	% bounds
	 yb = abs(sin(toradians(a))*rd)

	 if x<ox-rd then x=ox-rd		% keep inside
	 if x+siz > ox+xb then x=ox+xb-siz
	 if y<oy-rd then y=oy-rd
	 if y+siz>oy+yb then y=oy+yb-siz

	 gr.modify o, "x",x
	 gr.modify o, "y",y
	next
return
%--------------------------------------
ghost_detect:				% detect for ghost

 SENSORS.READ senG, gx, gy, gz		% acc/grv
 SENSORS.READ 2, mx, my, mz		% mag

 mmax = sqr( mx*mx + my*my + mz*mz)
 my = my - sgn(my)* mmax * (1-gz/9.81)		% compensate for Z tilt
 if my>0 then N=-360 else N=180
 ang= abs(N) + ( sgn(N) * int(mx/31.869*90) )
 if ang > 180 then ang -= 360			% -180..+180 from N -ve anti
 strength=abs(abs(mx)-abs(my))

 dis=(range-strength)/(range-sensi) * rd	% stronger=closer
return					% dis,ang
%--------------------------------------
