% console widget < HEW framework < public domain. by humpty.drivehq.com
% Requires: txtscroll.bas
% v4.2

fn.def con_make (aux$, bsize, x,y,ww,wh)	% constructor

 list.create s, tlist				% buffer list

 wg= txtscroll_make (aux$, tlist, x,y,ww,wh)	% use a txtscroll widget

 bundle.put wg, "type", "console"
 bundle.put wg, "tlist", tlist
 bundle.put wg, "bsize", bsize
 fn.rtn wg
fn.end
%---------------------------------------
fn.def con_bulk (blist, wg)		% bulk printing
   cmd$="bulk"
   goto con_entry
fn.end
fn.def con (cmd$, t$, wg)		% common callback

con_entry:
   bundle.get wg, "tlist", tlist
   bundle.get wg, "bsize", bsize
   bundle.get wg, "topw", top		% first line in wdw
   bundle.get wg, "nrows", nrows	% # rows in wdw

   list.size tlist, last

   sw.begin cmd$
   sw.case "print"
	   gosub con_print
	   gr.render
	   sw.break
   sw.case "touch"
	   call txtscroll ("touch", 0, wg)
	   sw.break
   sw.case "tag"			% add t$ to end of last line
	   if !last then list.add tlist,"":last=1	% was empty list
	   list.get tlist,last, s$
	   list.replace tlist,last, s$+t$
	   call txtscroll ("printrow", last, wg)	% display
	   sw.break
   sw.case "bak"			% back space
	   if !last then sw.break	% empty list
	   list.get tlist,last, s$
	   if s$="" then sw.break	% cant bakspc an empty line
	   list.replace tlist,last, left$(s$,-1)
	   call txtscroll ("printrow", last, wg)	% display
	   sw.break
   sw.case "clear"			% clear console
	   list.clear tlist
	   call txtscroll ("goto",1,wg)
	   sw.break
   sw.case "raw"			% raw text mode ?
	   call txtscroll ("raw", val(t$), wg)
	   sw.break
   sw.case "bulk"			% bulk printing
	   list.size blist,n
	   list.add.list tlist, blist
	   gosub con_fast
	   sw.break
   sw.end
fn.rtn 0
%---------------------------------------
con_print:
	   split.all a$[],t$, "\\n"
	   array.length n, a$[]
	   list.add.array tlist, a$[]
	   undim a$[]
con_fast:
	   if top < last-nrows then		% if not last page
	      top = last-nrows+1
	      rc= txtscroll ("goto", top,wg)	% goto last page
	   endif

	   for i = last+1 to last+n
	       call txtscroll ("printrow", i, wg)	% display if in view
	   next
	   call txtscroll ("scroll", -1*n, wg)	% scroll up
	   last = last+n
	   if last <= bsize then return		% overflow ?

	   n=last-bsize
	   for i=1 to n
	       list.remove tlist, 1		% delete 1st row
	   next
	   last = bsize
	   bundle.get wg, "topw", top		% update row pointers
	   bundle.put wg, "topw", top-n
	   bundle.get wg, "nxtrow", nxtrow
	   bundle.put wg, "nxtrow", nxtrow-n
	   bundle.get wg, "prvrow", prvrow
	   bundle.put wg, "prvrow", prvrow-n

	   if bsize < nrows then		% if buffer is smaller than wdw
	      call txtscroll ("goto", 1, wg)	% refresh the wdw with new top
	   endif
return
%---------------------------------------
fn.end
%---------------------------------------
