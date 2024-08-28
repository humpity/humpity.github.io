% init.bas < HEW framework < public domain. by humpty.drivehq.com
% v5.1
fn.def init_hew()			% initialise screen and globals

 bundle.create globals			% global var store hack. must be 1.

 call theme_init ()			% init colors
 bundle.get 1, "theme", theme
 bundle.get theme, "p_canvas", c$    	% get canvas color
 a=val(word$(c$,1,","))
 r=val(word$(c$,2,","))
 g=val(word$(c$,3,","))
 b=val(word$(c$,4,","))
%---------------------------------------
 sbar = 1				% status bar on/off
 scr_orient = -2			%  0=landscape, 1=portrait
					% -1=dont-fix, -2=auto-fix
 if scr_orient < 0 then o=-1 else o=scr_orient
 gr.open a,r,g,b,sbar,o
 pause 1000				% settle orientation
 if sbar then gr.statusbar sbar else sbar=0	% status bar height
 sbar=int(sbar)
 gr.screen act_w, act_h, density	% the physical running device sizes

 dev_w = 320			 	% development device width,height..
 dev_h = 480				% ..used for scaling and ratio fix

					% match dev orientation to actual
 if dev_w < dev_h & act_w > act_h then swap dev_w, dev_h
 if dev_w > dev_h & act_w < act_h then swap dev_w, dev_h

 if scr_orient = -2 then		% auto fix orientation to detected
	if dev_w < dev_h then scr_orient=1 else scr_orient=0
	screen.rotation r		% modify for reversed
	if r<2 then gr.orientation scr_orient else gr.orientation scr_orient+2
 endif

 scaling = 0				% if using scaling set this to 1
 if scaling then
	scr_w = dev_w
	scr_h = dev_h
	scale_x = act_w / dev_w		% scale..
	scale_y = act_h / dev_h		% ..by..
	scalexy = min (scale_x, scale_y)	% ..shortest ratio
	scale_x = scalexy		% ..keeps everything inside and
	scale_y = scalexy		% ..prevents scale distortion
	gr.scale scale_x, scale_y
	srows = 17			% define #rows manually
	row_h = int(scr_h/srows)	% determine row height by srows
 else
	scale_x = 1			% no scaling
	scale_y = 1
	scr_w = int(act_w)
	scr_h = int(act_h)
					% uncomment if want fix aspect ratio
	%~ if scr_h > scr_w then
	   %~ scr_h = dev_h * (act_w / dev_w) % cuts longest side to short ratio
	%~ else
	   %~ scr_w = dev_w * (act_h / dev_h)
	%~ endif

	row_h = 28			% define row height manually
	row_h = int(row_h*density/160)	% correct for density
	srows = int(scr_h/row_h)	% define #rows by row height
 endif
 txt_h = int(row_h*5/6)			% insert a nice gap between text lines
%---------------------------------------
 bundle.put 1, "scale_x",scale_x
 bundle.put 1, "scale_y",scale_y
 bundle.put 1, "srows", srows		% # of screen rows
 bundle.put 1, "scr_w", scr_w		% screen width
 bundle.put 1, "scr_h", scr_h		% screen height
 bundle.put 1, "row_h", row_h		% row height
 bundle.put 1, "txt_h", txt_h		% text height
 bundle.put 1, "timeout", 0		% event timeout flag
 bundle.put 1, "isr$", ""		% interrupt msg/flag
 bundle.put 1, "evt_shell",0		% check for shell event
 bundle.put 1, "scr_orient", scr_orient % orientation 0=landscape, -1=not fixed
 bundle.put 1, "sbar",sbar		% status bar height

 list.create N, widgets			% main detection callback list
 bundle.put 1, "widgets", widgets
fn.end % init_hew
%---------------------------------------
