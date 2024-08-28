% progress bar widget < HEW framework < public domain. by humpty.drivehq.com
% v2.0
fn.def progress_make ()            % constructor
                                        % non-detectable
                                        % depends on gr.text.size
        bundle.get 1, "scr_w", scr_w
        bundle.get 1, "scr_h", scr_h

 gr.text.align 1
 gr.get.textbounds chr$(hex("2588")),l,t,r,b         % dot width,height

 dt_height = b-t
 dt_width  = r-l
 l=scr_w/7
 t=scr_h*4/10
 r=scr_w*6/7
 b=t+dt_height*1.5

 maxdots = floor((r-l)/dt_width)     % progress full
 maxdots$=""
 for i=1 to maxdots
     maxdots$ += chr$(hex("2588"))
 next
 ndots=0
 call theme_color ("p_prg_border")     % border + background
 gr.rect border, l,t,r,b
 gr.set.stroke 0                        
 gr.text.bold 0
 call theme_color ("p_prg_dots")        % dots inside
 gr.text.draw gdots,l+dt_width/5,b-dt_height*0.41,""

 gr.hide border
 gr.hide dots
 bundle.create wg                 % create & return wg record
 bundle.put wg, "type", "progress"     % record the object name and state
 bundle.put wg, "left", l
 bundle.put wg, "top",  t
 bundle.put wg, "right", r
 bundle.put wg, "bottom", b
 bundle.put wg, "border", border
 bundle.put wg, "gdots", gdots
 bundle.put wg, "maxdots", maxdots$
 bundle.put wg, "ndots", ndots

 fn.rtn wg
fn.end
%---------------------------------------
fn.def progress (cmd$, num, wg)              % callback

       bundle.get wg, "border", border
       bundle.get wg, "gdots", gdots
       bundle.get wg, "maxdots", maxdots$
       bundle.get wg, "ndots", ndots

       max=len(maxdots$) 
       sw.begin cmd$
       sw.case "show"
                gr.show border
                gr.show gdots
                sw.break 
       sw.case "hide"
                gr.hide border
                gr.hide gdots
                sw.break 
       sw.case "inc"                    % increase dots
                ndots++
                if ndots > max then ndots=1
                s$ = left$ (maxdots$, ndots)
                gr.modify gdots, "text", s$
                bundle.put wg, "ndots", ndots
                sw.break
       sw.case "set"                    % set to fraction 0-1
                ndots = num * max
                if ndots > max then ndots=max
                s$ = left$ (maxdots$, ndots)
                gr.modify gdots, "text", s$
                bundle.put wg, "ndots", ndots
                sw.break
       sw.end 
       gr.render
fn.end
%---------------------------------------

