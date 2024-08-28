% about screen
%---------------------------------------
about_init:
list.create s, about_typ
list.add about_typ,~
                "title",~
                "label",~
                "menu",~        % 3
                "label",~
                "menu",~        % 5
                "label",~
                "menu"        % 7
list.create s, about_lab           % label/question
list.add about_lab,~
                "Radar Ghost|v1.0",~
                "~Credits",~
                "rfo-basic|Basic engine (GPL)",~	% 3
                "",~
                "HEW widgets|(Public Domain)",~		% 5
                "",~
                "~Ghost Theory 2|by Fonts bomb"			% 7
list.create s, about_val           % value (must be text)
list.add about_val,~
                "C",~
                "",~
                "",~
                "",~
                "",~
                "",~
                ""

wg_formA= pickform_make (scr_w , -1 , -1, -1, about_typ, about_lab, about_val)

return %_about_init
%---------------------------------------
about_get:                                % get settings from user

	row=pickform ("input","right",wg_formA)
        sw.begin row
           sw.case 3
                browse "http://rfobasic.freeforums.org/"
           sw.break
           sw.case 5
                browse "http://humpty.drivehq.com/promotes/rfo-basic/hew/hew.html"
           sw.break
           sw.case 7
                browse "http://www.dafont.com/ghost-theory.font"
           sw.break
        sw.end
        if row =0 | row > 7 then return
        do
         pause 200
         if !background() then d_u.break % force wait until foreground
        until 0
return %_about_get
%---------------------------------------

