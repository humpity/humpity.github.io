% initialise forms and pick lists
init_forms:

gr.text.size th*0.8              % set font size
%-------------------------------------- % SubForm 2 - Shades

list.create s, set2_typ
list.create s, set2_lab
list.create s, set2_val

list.add set2_typ, "title","menu","menu","menu","menu","menu","menu","menu"
list.add set2_lab, "Shade","Light","Pale", "Bright","Normal", "Sheen","Deep","Dark"
list.add set2_val, "C","C","C","C","C","C","C","C"
                                        % subform2 is embedded in subform1
                                        % so it must be created first
wg_subf2= pickform_make (0,0, th*5, th*8, set2_typ, set2_lab, set2_val)
%-------------------------------------- % SubForm 1 - Colors
list.create s, set1_typ
list.create s, set1_lab
list.create s, set1_val

wg$=int$(wg_subf2)                      % subform2 ID MUST be a string

list.add set1_typ, "title","subform|"+wg$,"subform|"+wg$,"subform|"+wg$,"subform|"+wg$
list.add set1_lab, "Color", "Red", "Blue", "Yellow","Green"
list.add set1_val, "C","R","R","R","R"
                                        % subform1 is embedded in other forms
                                        % so it must be created first
wg_subf1= pickform_make (0,0, -1, -1, set1_typ, set1_lab, set1_val)
%-------------------------------------- % Main Form
list.create s, setM_typ          % type:checkbox|text_in|radio|menu|counter|title
list.create s, setM_lab          % label/question
list.create s, setM_val          % value (must be a text string)

list.add setM_typ~
                "title"~
                "subform|"+int$(wg_subf1)~  % subform1 embedded (must be string)
                "counter|1,60"~
         "picklist|Fruit,Apple,Banana,Orange,Grape"~  % picklist embedded
                "label"~
                "radio"~
                "radio"~
                "integer"~
                "checkbox"~
                "text_in"~
                "real"~
                "menu"~
                "menu"~
                "subform|"+int$(wg_subf1)~  % subform1 embedded (must be string)
                "counter|10,30"~
                "label"~
                "radio"~
                "radio"~
                "integer|1,1000"~
                "checkbox"~
                "text_in"~
                "label"~
                "menu"~
                "menu"~
                "menu"
list.add setM_lab~
                "Settings"~
                "Color"~                % subform1
                "Pool|1..60"~
                "Fruit"~                % picklist
                ""~
                "Lucky Balls|Only if you feel lucky"~
                "Nice Draws"~
                "Integer"~
                "Disable luck"~
                "Message"~
                "Real"~
                "Cancel"~
                "Save"~
                "Color2"~               % subform1
                "Pool2|10..30"~
                ""~
                "~Lucky Balls2|(suppress next seperator)"~
                "Nice Draws2"~
                "Integer range|1..1000"~
                "Disable luck2"~
                "Message2"~
                ""~
                "Cancel2"~
                "Save2"~
                "last item"
list.add setM_val~
                "C"~
                "C"~
                "49"~
                "Apple"~                % listpick current value
                ""~
                "0"~
                "1"~
                "21"~
                "0"~
                "Some Text"~
                "123.45"~
                "C"~
                "C"~
                ""~
                "12"~
                ""~
                "0"~
                "1"~
                "77"~
                "0"~
                "Some Text"~
                ""~
                "C"~
                "C"~
                ""
! Instantiate multiple copies of the main form with differing sizes,position

wg_form1= pickform_make (0 , sh*0.1 , -1, -2, setM_typ, setM_lab, setM_val)

wg_form2= pickform_make (sw,   sh*0.2, -1, -2, setM_typ, setM_lab, setM_val)
wg_form3= pickform_make (sw*0.9,   0, -1, sh*0.5, setM_typ, setM_lab, setM_val)

wg_form4= pickform_make (-1,   sh*0.6, -1, sh*0.5, setM_typ, setM_lab, setM_val)

			% bigger fonts for some forms
gr.text.size th*0.9
wg_form5= pickform_make (-1,-1,-1,-2, setM_typ, setM_lab, setM_val)
gr.text.size th
wg_formfull= pickform_make (0,0, sw, sh, setM_typ, setM_lab, setM_val)
return
