% keyboard input widget < HEW framework < public domain. by humpty.drivehq.com 
% v1.2
fn.def keyinp_make ()                   % constructor
                                        % gr.text.size will be normalised
        bundle.get 1, "scr_w",scr_w
        bundle.get 1, "scr_h",scr_h
 gr.text.height theight
 row_height = int(theight *5/4)
 pad = ceil(row_height/20)              % padding from text wdw to border
 x=scr_w*0.01                           % pos is always at top of screen
 y=scr_h*0.01

 bw = scr_w-x
 bh = row_height*2
 ww = bw-2*pad                          % text area
 wh = row_height
 lh = theight                           % label height
 l=pad                                  % txt wdw rel.bmp
 r=l+ww-1
 t=pad+lh
 b=bh-pad

 gr.bitmap.create bmp, bw, bh           % bmp encloses all
 gr.bitmap.drawinto.start bmp

 call theme_color ("p_kin_border")      % background border
 gr.rect o, 0,0,bw,bh

 dat$ = "Enter Text >"
 gosub keyinp_label                     % draw label

 gr.set.stroke 2
 call theme_color ("p_kin_backg")      % text background
 gr.rect o_bord,l,t,r,b

 gr.bitmap.drawinto.end
 gr.bitmap.draw o_bmp, bmp,x,y

 gr.text.size theight                   % main text
 gr.set.stroke 0
 call theme_color ("p_kin_text")
 gr.clip o, x+l, y+t, x+r, y+bh, 0      % clip it
 gr.text.draw o_txt,x+l,y+t+row_height-row_height/4,""
 gr.clip o, 0, 0, scr_w, scr_h, 2       % release clip

 kb.hide
 gr.hide o_bmp
 gr.hide o_txt

 bundle.create wg                       % create & return wg record
 bundle.put wg, "type", "keyinp"
 bundle.put wg, "left", l               % txt area
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "pad", pad
 bundle.put wg, "height", theight
 bundle.put wg, "o_bmp", o_bmp
 bundle.put wg, "o_txt", o_txt
 bundle.put wg, "text", ""              % the actual text
 bundle.put wg, "mode", 1               % default mode is
                                        % 0=off, 1=once, 2=stay

 bundle.put 1, "keyinp", wg             % save myself to global bundle
fn.end
%---------------------------------------
fn.def keyinp (cmd$, dat$)              % callback routine
                                        % get input, result in dat$
                                        % rc=0=>ok. rc=1=>BK. rc=2=>BK+close
        bundle.get 1,  "keyinp",wg

        bundle.get wg, "left", l
        bundle.get wg, "top",  t
        bundle.get wg, "right", r
        bundle.get wg, "bottom", b
        bundle.get wg, "pad", pad
        bundle.get wg, "height", theight
        bundle.get wg, "o_bmp", o_bmp
        bundle.get wg, "o_txt", o_txt
        bundle.get wg, "text", tx$
        bundle.get wg, "mode", mode     % show mode

        gr.text.size theight            % recall height
        row_height = int(theight *5/4)
        ww = r-l+1                      % txt wdw
        wh = b-t+1
        rc = 0
        sw.begin cmd$
        sw.case "input"                 % get input into dat$
                gosub keyinp_inp
                sw.break
        sw.case "get"
                dat$ = tx$             % return current text
                sw.break
        sw.case "put"                   % overwrite current text
                gr.modify o_txt, "text", dat$
                bundle.put wg, "text", dat$     % save the new string
                sw.break
        sw.case "label"
                 gr.get.value o_bmp, "bitmap", bmp
                 gr.bitmap.drawinto.start bmp
                 gr.bitmap.size bmp, bw,bh

                 gosub keyinp_label             % change label
                 gr.bitmap.drawinto.end
                sw.break
        sw.case "setmode"               % change mode to dat$
                gosub keyinp_mode
                sw.break
        sw.case "getmode"               % getmode to rc
                rc=mode
                sw.break
        sw.end
fn.rtn rc
%---------------------------------------
keyinp_inp:                             % get input line
        key_tab$="*#************************************"+~ % 17-54
                 ",.***********`-=[]\\;'/@***+"            % 55-81
        shift_tab$= "\"****<_>?" + ")!@#$%^&*(" + "*:*+***" +~ % 39-64
                    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "{|}**~" +~  % 65-96
                    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"                % 97..
        alt_tab$= "<***********>"     % alt-left 98-110

        gr.get.position o_txt, x0,y0
        gr.text.width cw,"_"

        if mode=1 then gosub keyinp_show  % show it if mode=once
        s$=dat$                         % get initial string if any
        gr.modify o_txt, "text", s$+"_"
        gr.render
        k$=""
        while 1
              if bk_pressed() then w_r.break
              inkey$ k$
              pause 50
              if k$="@" then w_r.continue
              if k$="key 66" then w_r.break     % break on ENTER
              gosub keyinp_trans                % translate key k$ to s$

              gr.modify o_txt, "text", s$+"_"

              gr.text.width w,s$                % test for overflow
              if (w+cw) > (r-l) then
                 gr.modify o_txt, "x", x0-w-cw+r-l
              else
                 gr.modify o_txt, "x",x0        % restore position
              endif
              gr.render
        repeat
        gr.modify o_txt, "x",x0                 % restore position

        if mode=1 then gosub keyinp_hide        % once only mode
        if bk_pressed() then                    % if backkey
           rc=1                                 % inform backkey pressed
           s$=""                                % return nothing
           gosub keyinp_hide                    % close keyboard
           if mode=2 then
              rc=2                              % inform kbd closed
              mode=1                            % set mode to once
              bundle.put wg, "mode", mode       % and save it
           endif
	   isr_set("")				% clear interrupt
        endif
        dat$ = s$
return
%---------------------------------------
keyinp_trans:                           % translate key in k$ to s$

        if word$(k$,1) <> "key" then goto keyinp_char  % not key code
        n = val(word$(k$,2))            % key code keynum
        ln=len(s$)
        sw.begin n
        sw.case 67                              % delete key
                if ln then s$= left$(s$, ln-1)  % delete last char
                k$=""
                sw.break
        sw.case 59                              % left-shift
                c$=right$(s$,1)                 % get last char
                if c$ >="'" & c$ <="z" then      % in shift table ?
                   s$= left$(s$, ln-1)          % delete last char
                   k$=mid$(shift_tab$,ascii(c$)-38,1)   % replace with this
                endif
                sw.break
        sw.case 57                              % left-alt
                c$=right$(s$,1)                 % get last char
                if c$ >="b" & c$ <="n" then     % in alt table ?
                   s$= left$(s$, ln-1)          % delete last char
                   k$=mid$(alt_tab$,ascii(c$)-97,1)   % replace with this
                endif
                sw.break
        sw.default
                 if (n<17 | n>81) then
                    k$=""                       % not recognised
                 else
                    k$ = mid$(key_tab$,n-16,1)     % translate
                 endif
        sw.end
keyinp_char:
        s$= s$ + k$                     % add char
return
%---------------------------------------
keyinp_mode:                            % change mode
        if dat$="once" then
           mode = 1
           gosub keyinp_hide
           pause 100
        endif
        if dat$="stay" then
           gosub keyinp_show
           mode = 2
        endif
        bundle.put wg, "mode", mode
return
%---------------------------------------
keyinp_show:
        kb.hide
        pause 100
        kb.toggle
        pause 100

        gr.get.position o_bmp, x0,y0
        gr.get.value o_bmp, "bitmap",bmp
        gr.bitmap.size bmp,w,h
        gr.modify o_bmp, "y", y0-h
        gr.show o_bmp
        s=h/5
        for y= y0-h+s to y0 step s
            gr.modify o_bmp, "y", y
            gr.render
        next
        gr.modify o_bmp, "y", y0

        gr.show o_txt
        gr.render
return
%---------------------------------------
keyinp_hide:
        kb.hide

        gr.hide o_txt
        gr.get.position o_bmp, x0,y0
        gr.get.value o_bmp, "bitmap",bmp
        gr.bitmap.size bmp,w,h
        s=h/5 * -1
        for y= y0 to y0-h step s
            gr.modify o_bmp, "y", y
            gr.render
        next
        gr.hide o_bmp
        gr.modify o_bmp, "y", y0
        gr.render
return
%---------------------------------------
keyinp_label:                           % change the label to dat$

 gr.text.size theight*0.8                   % is smaller
 call theme_color ("p_kin_border")      % blankout label
 gr.rect o, pad,pad,bw-2*pad,theight

 call theme_color ("p_kin_label")       % label text
 gr.text.align 1
 gr.set.stroke 0
 m$ = word$(dat$, 1, "\\|")             % main
 s$ = word$(dat$, 2, "\\|")             % embedded
 if s$ = "I" then gr.text.skew -0.25    % italics

 gr.text.draw o,pad,theight*4/5,m$
 gr.text.skew 0
return
%---------------------------------------
fn.end
