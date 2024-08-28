% post-init, misc functions, choose sensor api
%--------------------------------------
fn.def movef2b ()                 	% move front obj to back
        gr.getdl d[]
        array.length l, d[]
	dim n[l]
	n[1]=d[l]
	array.copy d[1,l-1], n[2]
        gr.newdl n[]
fn.end
%--------------------------------------
fn.def msg_out (s$)                     % popup a msg (!=4secs else 2)
   gr.screen scr_width, scr_height
   foursec=0
   if left$ (s$,1) = "!" then
      foursec=1
      s$=mid$(s$,2)
   endif
   popup s$, scr_width*0.2,scr_height*0.3, foursec
fn.end
%---------------------------------------
fn.def versNN ()			% get android version as NN
	a=0
	device a
	bundle.get a, "OS", s$
	v= val(word$(s$,1,"\\."))*10 + val(word$(s$,2,"\\."))
fn.rtn v
fn.end
!---------------------------------------
! open & pick the correct sensor APIs according to android version
if versNN()>=23 & !foapi then goto misc_skip1
!print "<=froyo"
					% API 3 to 8
fn.def get_bearing()			% get N bearing from us -ve=anti

	sensors.read 3, oa, op, or	% orn (1.5-2.2x Froyo) clock 0..360
	if oa >180 then oa-=360		% angle in degrees -180 to +180
fn.rtn	oa*-1				% N bearing from us is opposite
fn.end
senG=1					% acc+grv (better than nothing)
sensors.open 2,1,3			% mag,acc+grv,ori
%--------------------------------------
goto misc_skip2
misc_skip1:
!print ">=ginger"
					% API 9
fn.def get_bearing()			% get N bearing from us -ve=anti

	sensors.read 11, rx, ry, rz	% rot (2.3 Gingerbread>) +ve anti
fn.rtn int(todegrees(2*asin(rz)))	% N bearing from us is same +ve clock
fn.end
senG=9					% proper gravity
sensors.open 2,9,11			% mag,grv,rot
%--------------------------------------
misc_skip2:
wakelock 2				% keep alive but dimmed
