% button timer widget. < HEW framework < public domain. by humpty.drivehq.com
% v2.1
% 99:59 timer
fn.def btimer_make (aux$,style, x,y)  % constructor
                                        % depends on gr.text.size
                                        % x,y is the top left corner of box

 wg = button_make (aux$, " 0:00", style,x,y)    % make a button

                                        % add some timer stuff to widget

 bundle.put wg, "tsecs", 60             % total secs
 bundle.put wg, "secs", 60              % seconds left
 bundle.put wg, "is_running", 0         % timer is counting ?
 bundle.put 1,"wg_timer", wg            % define timer globally

 fn.rtn wg
fn.end
%---------------------------------------
fn.def btimer (cmd$, t$, wg)            % callback

call isr_set("btimer")

 bundle.get wg, "tsecs", tsecs          % total mins
 bundle.get wg, "secs", secs            % seconds left
 bundle.get wg, "is_running", is_running  % timer is running ?
 bundle.get wg, "g_text", g_text
 gr.get.value g_text, "list", tlist     % button text

 rc=0                                   % default return code
       sw.begin cmd$
       sw.case "dec"                    % count down
                if t$="" then num=1 else num = val(t$)
                secs=secs-num
                if secs < 0 then secs=0
                gosub btimer_print
                rc=secs                 % return remaining secs
                sw.break
       sw.case "stop"                   % stop timer
                timer.clear
                bundle.put wg,"is_running", 0
                sw.break
       sw.case "start"                  % start timer
                if is_running then sw.break
                bundle.put wg,"is_running", 1
                timer.set 1000
                sw.break
       sw.case "is_running"             % query timer
                rc= is_running
                sw.break
       sw.case "reset"                  % set or ""=reset max 0-599
                timer.clear
                bundle.put wg,"is_running", 0
                if t$ <> "" then
                   colon = is_in (":", t$)
                   if colon then
                      tmins$ = left$(t$, colon-1)
                      tsecs$ = mid$ (t$, colon+1)
                   endif
                   if tmins$="" then tmins=0 else tmins=val(tmins$)
                   if tsecs$="" then tsecs=0 else tsecs=val(tsecs$)
                   tsecs = 60*tmins + tsecs
                   bundle.put wg, "tsecs", tsecs        % new total
                endif
                secs = tsecs
                gosub btimer_print
                sw.break
       sw.default
                call button (cmd$, t$, wg)      % call parent class cmd
       sw.end
fn.rtn rc
btimer_print:
                m = secs/60
                s = mod (secs, 60)
                t$ = right$(format$("#%",m),2)+":"+right$(format$("%%",s),2)
                list.get tlist,1,o              % get text
                gr.modify o, "text", t$
                bundle.put wg, "secs", secs
                gr.render
                return
fn.end
%---------------------------------------
goto btimer_skip                        % skip code at startup
ontimer:
        bundle.get 1,"wg_timer", wg_timer
        if btimer ("dec", "", wg_timer) < 1 then        % tick down
           call btimer ("stop", "", wg_timer)
           call button ("flash", "2", wg_timer)  % flash to indicate

           % put your code here <= when countdown reaches zero

        endif
        timer.resume
btimer_skip:
