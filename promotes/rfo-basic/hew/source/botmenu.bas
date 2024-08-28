% bottom menu widget. < HEW framework < public domain. by humpty.drivehq.com
% v4.1
                                        % 6 panel bottom sliding menu
fn.def botmenu_make (itms)              % constructor
                                        % supply 6 items or less
                                        % return itm# or 0 for quit
                                        % size depends on gr.text.size
        bundle.get 1, "scale_x",scale_x % get global vars (hack)
        bundle.get 1, "scale_y",scale_y
 list.size itms, last

 gr.screen scr_w, scr_h
 scr_w = scr_w / scale_x
 scr_h = scr_h / scale_y
 gr.text.typeface 3
 gr.get.textbounds "Hg",l,t,r,b

 th = b-t                               % text height
 padx = th                              % horz padding
 pady = th*2                            % vert padding determines cell height
 ch = th + pady                         % cell height + padding
 cw = scr_w/3                           % cell width
 ww = scr_w                             % widget width
 wh = ch*2                              % widget height

 l = 0                                  % widget rect
 t = scr_h - ch*2
 r = scr_w
 b = scr_h

 gr.bitmap.create bmp, ww, wh        % the bitmap
 gr.bitmap.drawinto.start bmp

 gr.set.stroke 0
                                        % background
 call theme_color ("p_btm_backg")
 gr.rect o,0,0,ww,wh
                                        % grid
 call theme_color ("p_btm_grid")
 gr.line o, 5,ch, ww-5,ch
 gr.line o, cw,3, cw,wh-3
 gr.line o, cw*2,3, cw*2,wh-3
                                        % text
 call theme_color ("p_btm_text")
 gr.text.align 2                        % use center
 n=1
 for j=0 to 1 step 1
  for i=0 to 2 step 1
      s$ = ""
      if n <= last then list.get itms, n, s$
      gr.text.draw o, cw*i + cw/2, ch*j + pady/2+th*0.9, s$
      n++
  next i
 next j
 gr.text.align 1

 gr.bitmap.drawinto.end
 gr.bitmap.draw o_btm, bmp, l,b+1       % draw it and move it off screen
 gr.hide o_btm
                                        % flash bg
 call theme_color ("p_btm_flash_bg")      % itm flasher is not part of the bmp
 gr.rect o_flash,0,0,cw,ch
 gr.hide o_flash

 bundle.create wg                 % create & return wg record
 bundle.put wg, "left", l
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "ch", ch
 bundle.put wg, "cw", cw
 bundle.put wg, "last", last
 bundle.put wg, "o_btm", o_btm
 bundle.put wg, "o_flash", o_flash
 fn.rtn wg
fn.end
%---------------------------------------
fn.def botmenu (wg)                     % callback

        call isr_set ("botmenu")        % set interrupt flag for backkey
        bundle.get wg, "left", l
        bundle.get wg, "top",  t
        bundle.get wg, "right", r
        bundle.get wg, "bottom", b
        bundle.get wg, "ch", ch
        bundle.get wg, "cw", cw
        bundle.get wg, "last", last     % last item #
        bundle.get wg, "o_btm", o_btm
        bundle.get wg, "o_flash", o_flash

        bundle.get 1, "scale_x",scale_x % get global vars (hack)
        bundle.get 1, "scale_y",scale_y
        speed = (t-b)/10               % animation steps (-ve)
!-------                                % show it and scroll it
        gr.show o_btm
        for i=b to t step speed         % scroll up
            gr.modify o_btm, "y", i
            gr.render
        next i
        gr.modify o_btm, "y", t         % make sure we land accurately
        gr.render
!-------                                % wait for touch
        rc=0                            % default return code
        do   
          if bk_pressed() then d_u.break
          do
            pause 50
            if bk_pressed() then d_u.break
            gr.touch touched, x,y
          until touched
          do
            gr.touch touched,a,a
          until !touched
          x /= scale_x
          y /= scale_y

          if x<l | x>r | y<t  then d_u.break
          if y<t then d_u.continue

          row = floor((y-t)/ch)
          col = floor((x)/cw)
          nth = (row * 3) + col +1

          if nth<0 | nth>last then d_u.continue % illegal item
          gosub flash
          rc = nth                      % got item
          d_u.break
        until 0

        if bk_pressed() then rc = 0      % back key pressed
!-------
        for i=t+1 to b+1 step speed*-1            % scroll it down
            gr.modify o_btm, "y", i
            gr.render
        next i
!-------                                % now hide it
        gr.hide o_btm
        gr.render
fn.rtn rc
!-------                                
flash:                                  % press button or flash it
        x = col * cw
        y = row * ch
        gr.modify o_flash,"left",x
        gr.modify o_flash,"top",t+y
        gr.modify o_flash,"right",x+cw
        gr.modify o_flash,"bottom",t+y+ch
        gr.show o_flash
        gr.render
        pause 300
        gr.hide o_flash
        gr.render
        %~ pause 100                    % double flash
        %~ gr.show o_flash
        %~ gr.render
        %~ pause 200
        %~ gr.hide o_flash
        %~ gr.render
        return
fn.end
%---------------------------------------
