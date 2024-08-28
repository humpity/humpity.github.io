radar_init:

	gosub radar_make
	gr.bitmap.scale sbmp, bmp, 2*rd, 2*rd,0
	gr.rotate.start 0, ox,oy, o_rotR	% radar
	gr.bitmap.draw o_bmp, sbmp, ox-rd,oy-rd
	gr.rotate.end
	gr.bitmap.delete bmp
	gr.modify o_bmp, "alpha", 255

	gosub radar_grid
	gr.bitmap.draw o_grid, bmp, ox-rd,oy-rd
	gr.modify o_grid,"alpha",150

	%~ gr.rotate.start 0, ox,oy, o_rotN	% ref line
	%~ gr.color 200,255,0,0,0
	%~ gr.line o_lineN, ox,oy, ox+rd,oy	% our ref starts at 3oclock
	%~ gr.rotate.end
return
%--------------------------------------
radar_make:
	r=rd*2
	gr.bitmap.create bmp, 2*r, 2*r
	gr.bitmap.drawinto.start bmp
	gr.set.antialias 1
	gr.set.stroke 3
	k=255
	i=2
	for a= 0 to -359 step -1
	    if k>0 then k-= (k/(1.5*i++)) else k=0
	    gr.color k,0,200,0,0
	    gr.line o, r,r, r+r*cos(a*pi()/180), r+r*sin(a*pi()/180)
	next
	gr.bitmap.drawinto.end
return
%--------------------------------------
radar_grid:
	r=rd : l=r/20
	gr.bitmap.create bmp, 2*r, 2*r
	gr.bitmap.drawinto.start bmp
	gr.set.antialias 0
	gr.set.stroke 0
	theme_color ("p_grid_lines")
	for i= r/5 to r step r/5
	 gr.circle o,r,r,i
	 gr.line o,r+i-l,r,r+i+l,r	% markers
	 gr.line o,r-i-l,r,r-i+l,r
	 gr.line o,r,r-i-l,r,r-i+l
	 gr.line o,r,r+i-l,r,r+i+l
	next
	gr.bitmap.drawinto.end
return

