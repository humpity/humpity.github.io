% HEW gformfill demo. < HEW framework < public domain. by humpty.drivehq.com 
%v1.0
                                        % include functions here
include text.bas                        % text widget
include button.bas                      % button widget
include gformfill.bas
%---------------------------------------
include event.bas                       % event loop
include init.bas                        % init screen and globals

                                        % create objects
gr.text.typeface 3                      % sans serif
gr.text.size tx_height

wg_txt = text_make ("txt1", "text",1,  scr_w/3, scr_h/2)
wg_btntest= button_make ("btn_1", "Test", 3, scr_w*1/20, scr_h*4/10)
wg_btnexit= button_make ("btn_2", "Exit", 3, scr_w*1/20, scr_h*6/10)

                                        % build event detection list
list.add widgets, wg_btntest, wg_btnexit


call gformfill_make ()                  % create gformfill
gosub menu_make                         % make the menu list

gr.render                               % show objects
%---------------------------------------
do                                      % main loop
   wg= event_get ()                     % get an event
   if wg=0 then end                     % bakkey pressed, end program
   bundle.get wg, "name", wg_name$

   if starts_with ("btn_",wg_name$) then call button ("flash","",wg) % flash it
                                        
   sw.begin wg_name$                    % execute widget callbacks
   sw.case "btn_1"                      % test button pressed
           call text_do ("text", "calling gformfill..", wg_txt)
           gr.render
           gosub menu_get               % get row pressed
           call text_do ("text", str$(row)+" returned", wg_txt)
           gr.render
           sw.break
   sw.case "btn_2"                      % exit btn pressed
           end
           sw.break
   sw.end
until 0					% do forever
end
%=======================================
% gosub code here                       % include any other gosub code here

menu_make:
          list.create s, mytyp           % type:checkbox|text|radio|menu
          list.create s, mylab           % label/question
          list.create S, myval           % value (must be text)
          % add types
          list.add mytyp, "title",~
                          "checkbox",~
                          "counter",~
                          "radio",~
                          "radio",~
                          "text_in",~
                          "menu",~        % only menu items can return
                          "menu",~
                          "menu"
          % add labels
          list.add mylab, "Settings Page",~
                          "Checkbox test",~
                          "Pool 1..99",~
                          "Radio test",~
                          "Radio test",~
                          "Enter Text|Type in your name",~
                          "Tap here to share|(email to your friends)",~
                          "Cancel",~
                          "Save"
          % add values
          list.add myval, "center",~
                          "0"~
                          "07",~
                          "1",~
                          "0",~
                          "99",~
                          "center",~      % val will position menu labels
                          "left",~
                          "right"
return
%--------------------------
menu_get:
                        % the call (only menu items will return (it's row))
         row = gformfill (mytyp, mylab, myval)

         if row = 0 then
            print "Back Key was pressed. Now in main prog"
         else
            print "item ";row;" was pressed"
    
            list.size myval,lsize           % print all values
            for i = 1 to lsize
                list.get myval, i, v$
                print v$;"|";
            next
            print
         endif
return
end
%=======================================
include isr.bas                         % interrupt handlers
end
