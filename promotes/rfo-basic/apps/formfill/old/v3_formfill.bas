! formfill.bas v3.0
! Fill form options using html/css.(by humpty/freeware/no restrictions.)

fn.def formfill (itmtyp, itmstr, itmval)
   fn_scope$ = "formfill"

   file.root root$

   list.size itmtyp,lsize
   digits = floor(log10(lsize))+1               % fix width to max digits
   digits$= left$("%%%%%",digits)

   itm_html$ = "<html>\n"
   itm_html$ += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=0\">\n"
   itm_html$ += "<head><link rel=\"stylesheet\" href=\"file://"+root$+"/formfill.css\" type=\"text/css\">"
   itm_html$ += "</head><body>\n"
   itm_html$ += "<form action=\"FORM\" method=\"get\">\n"

   for i=1 to lsize
       itm$ = "itm"+right$(format$(digits$,i),digits) 
       list.get itmtyp,i,t$        % e.g checkbox|text
       list.get itmstr,i,s$        % e.g blue    |enter name:
       list.get itmval,i,v$        % e.g "1"     |john

       if left$(s$,1) <> "~"  then           % want separator ?
        itm_html$ += "<hr>"
       else
        s$ = mid$(s$,2)
        itm_html$ += "<hr id=\"hid_hr\">"
       endif
       b$=""                            % split any embedded sub txt
       sub = is_in ("|",s$)
       if sub then                          
          b$ = mid$(s$,sub+1)
          s$ = left$ (s$,sub-1)             
       endif
       if t$ = "comment" | t$="menu" then
          tit$="<div"
          sub$="<div"
          if is_in("!",v$) then                      % jump to item
             itm_html$ = replace$ (itm_html$, "<body>",~
                              "<body onload=\"location.href = '#jump'\">")
             tit$ += " id=\"jump\""
          endif
          if is_in("C",v$) then tit$ += " style=\"text-align:center;color:cyan\"" % center title
          if t$="menu" then tit$ +=" onclick=\"Android.dataLink('"+ itm$ +"');\""
          if s$ <> "" then itm_html$ += tit$+" class=\"normal\">"+ s$ + "</div>\n"
          if b$ <> "" then itm_html$ += sub$+" class=\"small\">"+ b$ + "</div>\n"
       else
          itm_html$ += "<label"
          if b$ = "R" then itm_html$ += " id=\"pos-right\""
          if b$ = "C" then itm_html$ += " id=\"pos-center\""
          itm_html$ += ">" + s$

          if t$="textarea" then
             itm_html$ += "<textarea"
          else
             itm_html$ += "<input type=\"" + t$ + "\""
             if b$="R" then itm_html$ += " class=\"ctl-left\"" % ctrl to left
          endif
          if t$="radio" then
           itm_html$ += " name=\"" + "radio" + "\" id=\"" + itm$ + "\""+" value=\""+itm$+"\""
           if val(v$) then itm_html$ += " checked"
          else
           itm_html$ += " name=\"" + itm$ + "\" id=\"" + itm$ + "\""
          endif
          if t$="checkbox" then if val(v$) then itm_html$ += " checked"
          if t$="text"     then itm_html$ += " value=\""+v$+"\""
          if t$="textarea" then itm_html$ +=">"+v$+"</textarea"
          if t$="submit"   then itm_html$ +=" value=\""+v$+"\""
          itm_html$ += ">"
         itm_html$ += "</label>\n"
       endif
   next
   itm_html$ += "</form></body></html>"

   html.open 0             % don't show notification bar (it get's in the way)
   html.clear.cache
   html.load.string itm_html$

   do
    do
      pause 50
      html.get.datalink data$
    until data$ <> ""
!print "data:";data$

    type$ = LEFT$(data$, 4)
    data$ = MID$(data$,5)                  % cut off 1st type
    if type$ = "LNK:" then                 % most browsers ret a LNK,(not FOR)
       p=Is_In ("FORM?",data$)
       if p then data$=mid$ (data$, p+5)   % get data direct, don't bother fwding
    !   html.load.url data$                % don't use fwd FOR: (old method)
       d_U.break                           % just break out with the data
    endif
    if type$ = "FOR:" then d_u.break       % some browsers ret direct with FOR
    if type$ = "BAK:" then d_u.break       % back key
    if type$ = "DAT:" then d_u.break       % menu item e.g DAT:itm2

   until 0
%-----------------------
   if type$="BAK:" then
      html.close
      fn.rtn 0                    % back key = 0
   endif
   if type$="DAT:" then           % menu ?
      html.close
      fn.rtn val(mid$(data$,4,digits)) % menu = itm no.
   endif

   rc=0                                    % collect values & return submit#
   for itm=1 to lsize
     itm$ = "itm"+right$(format$(digits$,itm),digits) 

     list.get itmtyp, itm, type$
     dlen = len(data$)
     Sw.begin type$

     Sw.case "checkbox"
        checked = Is_In(itm$+"=on", data$)
        if (checked)
           list.replace itmval, itm, "1"
        else
           list.replace itmval, itm, "0"
        endif
     Sw.break
     Sw.case "text"
     Sw.case "textarea"
        text= Is_In(itm$+"=", data$)
        if text then
           text+=5
           j=0
           for i= text to dlen
               if mid$(data$,i,1)="&" then f_n.break
               j++
           next
           t$ = mid$(data$,text, j)
           t$=replace$(t$, "+", " ")           % uncook..
           t$=replace$(t$, "%2C", ",")
           t$=replace$(t$, "%27", "'")
           t$=replace$(t$, "%40", "@")
           t$=replace$(t$, "%0D%0A", "\n")
           list.replace itmval,itm, t$
        endif
     Sw.break
     Sw.case "radio"
        text= Is_In("radio="+itm$, data$)            % e.g radio=itm2
        if text then
           list.replace itmval,itm, "1"
        else
           list.replace itmval,itm, "0"
        endif
     Sw.break
     Sw.case "submit"
        text= Is_In(itm$+"=", data$)
        if text then rc=itm                % return submit's item#
     Sw.end
   next
   html.close
fn.rtn rc
fn.end

