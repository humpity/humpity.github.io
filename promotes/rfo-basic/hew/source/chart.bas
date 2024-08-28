% Chart widget > HEW framework > public domain. by humpty.drivehq.com
% v1.1
!--------------------------------------
fn.def chart_make (x,y, w,h)		% instantiate an empty chart

	bundle.get 1, "scr_w", sw
	bundle.get 1, "scr_h", sh

	gr.text.height th		% fontsize based on current text size
	rh=round(th*6/5)		% so is row height
	if h<3*rh then h=3*rh		% minimum height
	if w<3*rh then w=3*rh		% minimum width
	r=x+w-1				% right
	b=y+h-1				% bottom

	gr.bitmap.create bmp, w,h
	theme_color ("p_ch_border")	% use border color (outer)
	gr.set.stroke 1			% ..fill
	gr.bitmap.drawinto.start bmp

	h-=2*rh				% room for title and footer
	w-=2*rh				% room for left and right axis
	gosub chart_clear
	title$="Chart"
	gosub chart_title

	gr.bitmap.drawinto.end
	gr.clip o_clip1, x, y, r, b, 0		% clip
	gr.bitmap.draw   o_bmp, bmp, x,y
	gr.clip o_clip2, 0, 0, sw, sh, 2	% release clip

	list.create N,all
	list.add all, o_clip1
	list.add all, o_bmp
	list.add all, o_clip2
	gr.group.list g_all, all
	gr.hide g_all

	bundle.create wg		% create & return wg record
	bundle.put wg, "type", "chart"
	bundle.put wg, "left", x	% outer x
	bundle.put wg, "top",  y	% outer y
	bundle.put wg, "right", r
	bundle.put wg, "bottom", b
	bundle.put wg, "height", h	% inner h
	bundle.put wg, "width", w	% inner w
	bundle.put wg, "o_bmp", o_bmp
	bundle.put wg, "g_all", g_all
	bundle.put wg, "rh",rh
	bundle.put wg,"ctype",0		% default is bar chart
	fn.rtn wg
!--------------------------------------
!common
chart_title:				% draw title$ at top of chart
	th=rh*0.8			% font size for title
	gr.text.size th
	c$=word$(title$,2,"\\|")	% get any embeded cmd
	title$=word$(title$,1,"\\|")	% strip it from title
	theme_color ("p_ch_title")
	tx=rh
	gr.text.align 1
	if c$="R" then			% right align
		tx=rh+w
		gr.text.align 3
	endif
	if c$="C" then			% centre
		tx=w/2+rh
		gr.text.align 2
	endif
	gr.text.draw o, tx,th,title$
	gr.text.align 1
return
chart_xlabs:				% print xlabels
	theme_color ("p_ch_axis")
	xend=0				% last xlabel endpoint
	for i=1 to npts
		x1=rh+x[i] : y1=rh+h+floor(1.5*nh)
		x$=xlab$[i]
		if x$="" then f_n.continue	% ignore nolabel
		gr.text.width xw,x$		% get width
		if x1-xw/2 < xend then f_n.continue	% ignore overlap
		gr.text.align 2
		gr.text.draw o, x1,y1,xlab$[i]
		gr.text.align 1
		gr.text.width sep,"_"		% add separator
		xend = x1+xw/2+sep		% new xlabel endpoint
	next
return
chart_clear:				% clear the chart
	gr.set.stroke 1			% accurate fills
	theme_color ("p_ch_border")	% outer background
	gr.rect o,0,0,w+2*rh-1,h+2*rh-1
	theme_color ("p_ch_backg")	% inner background
	gr.rect o,rh,rh,rh+w-1,rh+h-1
return
fn.end %_chart_make
!--------------------------------------
fn.def chart_type(ctype$,wg)		% set type
					% ctype: "line"->1 else bar
	if ctype$="line" then ctype=1 else ctype=0
	bundle.put wg,"ctype",ctype
fn.end %_chart_type
!--------------------------------------
fn.def chart_clear(title$,wg)		% clear chart with optional title

	bundle.get wg, "height", h	% inner height
	bundle.get wg, "width", w	% inner width
	bundle.get wg, "o_bmp", o_bmp
	bundle.get wg, "rh",rh

	gr.get.value o_bmp,"bitmap",bmp
	gr.bitmap.drawinto.start bmp
	gosub chart_clear
	gosub chart_title
	gr.bitmap.drawinto.end
	gr.render
fn.end %_chart_clear
!--------------------------------------
fn.def chart_draw (title$,data[],xlab$[],wg)	% load & draw chart

	bundle.get wg, "height", h	% inner height
	bundle.get wg, "width", w	% inner width
	bundle.get wg, "o_bmp", o_bmp
	bundle.get wg, "rh",rh
	bundle.get wg,"ctype",ctype

	array.length npts,data[]
	dim y[npts]
	dim x[npts]
	array.min mn,data[] : array.max mx,data[]	% range

	y_scl = h/(mx-mn)		% y scale
	x_inc = w/npts			% normalised x grid setp

	for i=1 to npts			% convert data
	    y[i] = data[i]-mn		% zero range
	    y[i] = mx-mn-y[i]		% invert y
	    y[i] *= y_scl		% normalise y
	    x[i] = (i-1)*x_inc+x_inc/2	% normalise x
	next

	gr.get.value o_bmp,"bitmap",bmp
	gr.bitmap.drawinto.start bmp

	gosub chart_clear		% clear chart
	gosub chart_title		% draw title

	if ctype then
		lw=rh*0.05		% line width
		theme_color ("p_ch_line")	% line color
	else
		lw=x_inc/2
		theme_color ("p_ch_bar")	% standard bar color
	endif
	gr.set.stroke lw
	gr.text.size rh*0.6		% font size for scales
	gr.get.textbounds "0", tl, tt, tr, tb
	nh=tb-tt			% number height

	x0=rh+x[1] : y0=rh+y[1]		% default hold point
	for i=1 to npts
		x1=rh+x[i] : y1=rh+h
		x2=rh+x[i] : y2=rh+y[i]

		if ctype then
			gr.line o,x0,y0,x2,y2	% line graph
			x0=x2 : y0=y2		% hold point
		else
			gr.line o,x1,y1,x2,y2	% bar graph
		endif

	next
	gosub chart_xlabs		% print x labels

	gr.text.align 1

	gap = chart_getgap (mx-mn)	% get gap

	while gap*y_scl < nh		% prevent overlapping y-labels
		gap*=2
	repeat
	gpow = chart_getpow(gap)	% get gap power
	start = ceil(mn/gap) * gap	% find nearest gap
					% get fp precision
	if gpow > 0 then p$="%.0f" else p$="%."+int$(abs(gpow))+"f"

	theme_color ("p_ch_axis")
	for v=start to mx step gap	% print scale
		y = (mx-v)*y_scl+rh
		gr.text.draw o, 0.1*rh,y+nh/2,using$("en",p$+"-",v)
!		gr.line o, 0,y,w,y	% grid
	next
					% print min & max on rhs
	gr.text.align 3
	if gpow >= 0 then p$="%.2f" else p$="%."+int$(abs(gpow-1))+"f"
	mx$=using$("en",p$,mx)
	mn$=using$("en",p$,mn)

	mx$=rtrim$(mx$,"0*")	% strip trailing 0s
	mx$=rtrim$(mx$,"\\.")	% strip trailing .s
	mn$=rtrim$(mn$,"0*")
	mn$=rtrim$(mn$,"\\.")

	gr.text.draw o, w+1.9*rh,rh+nh/2,mx$
	gr.text.draw o, w+1.9*rh,rh+nh/2+h,mn$
	gr.text.align 1
	gr.bitmap.drawinto.end
	gr.render
fn.end %_chart_draw
!--------------------------------------
fn.def chart_show (wg)			% show chart

	bundle.get wg, "g_all", g_all
	gr.show g_all
fn.end
!--------------------------------------
fn.def chart_hide (wg)			% hide chart

	bundle.get wg, "g_all", g_all
	gr.hide g_all
fn.end
!--------------------------------------
fn.def chart_getpow (p)		% get normalised powers of 10

	e=0			% assume p < 10
	while p < 10
		p*=10		% keep multiplying by 10
		e--
	repeat
	while p >= 10
		p/=10		% keep dividing by 10
		e++
	repeat
fn.rtn e
fn.end
!--------------------------------------
fn.def chart_getgap (range)		% get appropriate step gap for range r

	r=range
	if r>10 then
		p=0
		while r>10
			r/=10		% keep dividing by 10
			p++
		repeat
	else
		p=1
		while r<=10
			r*=10		% keep multiplying by 10
			p--
		repeat
	endif

	g=pow(10,p)
	if g>range/4 then g*=0.5	% make sure there are at least 3 gaps
fn.rtn g
fn.end
!--------------------------------------
fn.def chart_open (mode$,wg)		% show the chart with animation

	bundle.get wg, "left", left	% outer x
	bundle.get wg, "top",  top	% outer y
	bundle.get wg, "right", right
	bundle.get wg, "bottom", bottom
	bundle.get wg, "o_bmp", o_bmp
	bundle.get wg, "g_all", g_all

	ww=right-left+1
	wh=bottom-top+1
 no_trans=0
    sw.begin mode$
    sw.case "left"
       gr.modify o_bmp,"x",left-ww : dx=ww/8 : dy=0
       sw.break
    sw.case "right"
       gr.modify o_bmp, "x", right : dx= ww/-8 : dy=0
       sw.break
    sw.case "top"
       gr.modify o_bmp, "y", top-wh : dx=0 : dy=wh/8
       sw.break
    sw.case "bottom"
       gr.modify o_bmp, "y", top+wh : dx=0 : dy=wh/-8
       sw.break
    sw.default
       no_trans=1		% no transition found
    sw.end
    if no_trans then goto chart_open

    gr.show g_all		% show transitions
    for i= 1 to 8
	gr.move o_bmp, dx,dy
	gr.render
    next
chart_open:
    gr.modify o_bmp, "x", left, "y", top
    gr.show g_all
    gr.render
fn.end
!--------------------------------------
fn.def chart_close (mode$,wg)		% hide the chart with animation

	bundle.get wg, "left", left	% outer x
	bundle.get wg, "top",  top	% outer y
	bundle.get wg, "right", right
	bundle.get wg, "bottom", bottom
	bundle.get wg, "o_bmp", o_bmp
	bundle.get wg, "g_all", g_all

	ww=right-left+1
	wh=bottom-top+1
    no_trans=0
    sw.begin mode$
    sw.case "left"
       gr.modify o_bmp,"x",left : dx=ww/-8 : dy=0
       sw.break
    sw.case "right"
       gr.modify o_bmp, "x", left : dx= ww/8 : dy=0
       sw.break
    sw.case "top"
       gr.modify o_bmp, "y", top : dx=0 : dy=wh/-8
       sw.break
    sw.case "bottom"
       gr.modify o_bmp, "y", top : dx=0 : dy=wh/8
       sw.break
    sw.default
       no_trans=1		% no transition found
    sw.end
    if no_trans then goto chart_close

    gr.show g_all		% show transitions
    for i= 1 to 8
	gr.move o_bmp, dx,dy
	gr.render
    next
chart_close:
    gr.modify o_bmp, "x", left, "y", top
    gr.hide g_all
    gr.render
fn.end
!--------------------------------------
