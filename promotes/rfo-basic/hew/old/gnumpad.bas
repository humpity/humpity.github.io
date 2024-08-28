% gnumpad.bas. < HEW framework < public domain. by humpty.drivehq.com
% v2.2
fn.def gnumpad_make ()       % constructor
                                        % size depends on gr.text.size
 list.create S,btns
 list.add btns,"1","2","3","<","4","5","6","clr","7","8","9","OK","-+","0","."," "

 gr.text.height th                      % text height

 gosub gnumpad_init
 gr.text.width w, "0"
 maxw = int(ww/w)-4                     % max chars
 if maxw > 15 then maxw=15              % restrict to 15 else 'e' shows

 gr.bitmap.create bmp, ww, wh           % numpad canvas
 gosub gnumpad_drawpad                  % draw pad
 gr.bitmap.draw o_bmp, bmp, l,b+1       % move it off screen
 gr.hide o_btm
                                        % output text
 call theme_color ("p_gn_border")
 gr.rect o_text_bg, l,t-th*2,r,t-bpad        %-bpad
 gr.hide o_text_bg
 call theme_color ("p_gn_backgnd")
 gr.rect o_text_bd, l+bpad,t-th*2+bpad,r-bpad,t-2*bpad
 gr.hide o_text_bd
 call theme_color ("p_gn_text")
 gr.text.align 3
 gr.text.draw o_text, r-th/2, t-th*0.6, "_"
 gr.hide o_text

 call theme_color ("p_gn_press_bg")    % flasher
 gr.rect o_flash,0,0,cw,ch
 gr.hide o_flash
 call theme_color ("p_gn_press_txt")   % flash text
 gr.text.size ch*0.8
 gr.text.align 2                        % center
 gr.text.draw o_ftext, 0,0,""
 gr.hide o_ftext
 gr.text.size th

 bundle.create wg                 % create & return wg record
 bundle.put wg, "left", l
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "ch", ch
 bundle.put wg, "cw", cw
 bundle.put wg, "o_bmp", o_bmp
 bundle.put wg, "o_flash", o_flash
 bundle.put wg, "o_ftext", o_ftext
 bundle.put wg, "o_text", o_text
 bundle.put wg, "o_textme", o_text      % a copy of o_text
 bundle.put wg, "o_text_bd", o_text_bd
 bundle.put wg, "o_text_bg", o_text_bg
 bundle.put wg, "theight", th
 bundle.put wg, "maxwidth", maxw          % max chars
 bundle.put wg, "btns", btns
 bundle.put 1,"gnumpad",wg              % this widget is global
 fn.rtn wg
%---------------------
gnumpad_init:
        bundle.get 1, "scr_w",scr_w
        bundle.get 1, "scr_h",scr_h
 bpad = th/10                           % border thickness
 lpad = th/2                            % line padding
 pady = th/2                            % vert padding
 padx = th                              % horz padding
 ch = th + pady*2                       % cell height + padding
 cw = th + padx*2                       % cell width
 ww = cw*4                              % widget width
 wh = ch*4                              % widget height

 l = (scr_w-ww)/2                       % numpad rect
 b = scr_h
 t = b-wh+1
 r = l+ww       %-1
return
%---------------------
gnumpad_drawpad:                        % draw the main pad

 gr.bitmap.drawinto.start bmp

 call theme_color ("p_gn_border")      % border
 gr.rect o,0,0,ww,wh
 call theme_color ("p_gn_backgnd")     % background
 gr.rect o,bpad,bpad,ww-bpad,wh-bpad

 gr.set.stroke 0                        % grid
 call theme_color ("p_gn_border")
 for i=1 to 3
     if i=3 then w=ww-cw else w=ww-lpad
     gr.line o, lpad, i*ch, w,i*ch
     gr.line o, cw*i,lpad, cw*i,wh-lpad
 next

 call theme_color ("p_gn_text")        % btn text
 gr.text.align 2                        % center

 for i=0 to 15
     x = mod(i,4)*cw+cw/2
     y = floor(i/4)*ch+pady+th*0.9
     if i=11 then y=y+ch/4              % O
     list.get btns, i+1,s$
     gr.text.draw o, x, y, s$ 
 next

 gr.text.align 1
 gr.bitmap.drawinto.end
return %_drawpad
%---------------------
fn.end %_make
%---------------------------------------
fn.def gnumpad (cmd$,num)               % callback
                                        % return 0=OK or 1=quit

        bundle.get 1,"gnumpad",wg
        bundle.get wg, "left", l
        bundle.get wg, "top",  t
        bundle.get wg, "right", r
        bundle.get wg, "bottom", b
        bundle.get wg, "ch", ch
        bundle.get wg, "cw", cw
        bundle.get wg, "o_bmp", o_bmp
        bundle.get wg, "o_flash", o_flash
        bundle.get wg, "o_ftext", o_ftext
        bundle.get wg, "o_text", o_text
        bundle.get wg, "o_textme", o_textme
        bundle.get wg, "o_text_bd", o_text_bd
        bundle.get wg, "o_text_bg", o_text_bg
        bundle.get wg, "maxwidth", maxw
        bundle.get wg, "theight", th

        bundle.get wg, "btns", btns

        bundle.get 1, "scale_x",scale_x
        bundle.get 1, "scale_y",scale_y

        gr.text.size th
        gr.get.value o_bmp, "bitmap",bmp
        if cmd$="input" then goto gnumpad_input
                                                % special commands
        if cmd$="maxwidth" then bundle.put wg,"maxwidth",num
        if cmd$="txtobj" then                   % change text output object
           if !num then num=o_textme            % or restore it
           bundle.put wg, "o_text", num
        endif
        if cmd$="decimal" then                  % disable/enable decimal
           if num then s$="."  else s$=""
           list.replace btns, 15, s$
        endif
        if cmd$="negator" then                   % disable/enable negator
           if num then s$="-+" else s$=""
           list.replace btns, 13, s$
        endif
        gosub gnumpad_init
        gosub gnumpad_drawpad           % redraw pad
        fn.rtn 0                        % OK
gnumpad_input:
        v$=using$("","%.15f",num)  % use float for rounding
                                        % trim trailing decimal zeroes
        if is_in(".",v$) then v$= word$(v$,1,"\\.*0+$")       
        if num=0 then v$=""             % blank out any zero value
        gr.modify o_text, "text", v$+"_"
!-------                                % show it and scroll it
        inc=(b-t)/10
        dec=inc * -1
        gr.show o_bmp
        for i=b to t step dec    % scroll up
            gr.modify o_bmp, "y", i
            gr.render
        next i
        gr.modify o_bmp, "y", t         % make sure we land accurately
        if o_text=o_textme then         % show output if mine
           gr.show o_text
           gr.show o_text_bd
           gr.show o_text_bg
        endif
        gr.render
!-------
        quit=0
        do   
          do                            % wait for touch
            if bk_pressed() then d_u.break
            gr.touch touched, x,y
          until touched
          if bk_pressed() then quit=1

          let x = x/scale_x
          let y = y/scale_y

          if y<(t-th*2) then quit=1         % outside touched=quit
          if x<l | x>r then quit=1 
          if quit then d_u.break
          if y<t | x<l | x>r then d_u.continue  % ignore if not in pad
          row = floor((y-t)/ch)
          col = floor((x-l)/cw)
          n = (row * 4) + col +1

          if n<1 | n>16 then d_u.continue % illegal item
          gosub gnumpad_flash
          gosub gnumpad_update
          
        until n=-1                      % OK pressed
        if quit then goto gnumpad_close
!-------
        if v$=""|v$="-" then v$="0"     % disallow weird numbers
        if val(v$)=0 then v$="0"        % disallow -ve 0
        if str$(val(v$)) = "Infinity" then
           popup "Input Error! Number too big", 0,0, 0
        else
           num=val(v$)                     % return value
        endif
gnumpad_close:
        if o_text=o_textme then gr.hide o_text else gr.modify o_text,"text",v$
        gr.hide o_text_bd
        gr.hide o_text_bg
        gr.render
        for i=t+inc to b+inc step inc            % scroll it down
            gr.modify o_bmp, "y", i
            gr.render
        next i
        gr.hide o_bmp
        gr.render
        if quit then fn.rtn 1           % back key pressed or pressed outside
fn.rtn 0                                % OK
!-------                                
gnumpad_update:
        
  ln=len(v$)
  m=maxw-1
  if ascii(v$)=45 then m=maxw
  if ln>m & mod(n,4) & (n<>13) then return         % overflow

  sw.begin n
  sw.case 4                     % del
        if ln then v$= left$(v$, ln-1)  % delete last char
        if right$(v$,1)="E" then v$= left$(v$, ln-2)    % del exp
        sw.break
  sw.case 15                    % decimal
        list.get btns, 15, s$
        if s$="" then sw.break  % disabled decimal
        if !is_in (".",v$) then v$=v$+"."
        sw.break
  sw.case 13                    % negate
        list.get btns, 13, s$
        if s$="" then sw.break         % disabled negate
        if ascii(v$)=45 then v$=right$(v$,ln-1) else v$="-"+v$
        sw.break
  sw.case 8                     % clr
        v$=""
        sw.break
  sw.case 12                    % OK
        n=-1
        sw.break
  sw.default
        list.get btns, n,s$
        v$=v$+s$
  sw.end
  gr.modify o_text, "text",v$+"_"
  gr.render
return
!-------                                
gnumpad_flash:                          % press button or flash it
        x = col*cw + l
        y = row*ch + t
        rig = x+cw
        bot = y+ch

        if n=12|n=16 then            % btns for OK
           x= 3*cw+l
           y= 2*ch+t
           bot= y+2*ch
           n=12
        endif

        gr.modify o_flash, "left",x,"top", y,"right",rig,"bottom",bot
        list.get btns,n,s$
        gr.modify o_ftext, "x",x+cw/2, "y",y+ch*0.8, "text",s$

        gr.show o_flash
        gr.show o_ftext
        gr.render
        do
          pause 100
          gr.touch touched,a,a                  % wait for finger up
        until !touched
        gr.hide o_flash
        gr.hide o_ftext
        gr.render
        return
fn.end
%---------------------------------------
