% eliza module for hew terminal demo

eliza_do:
        rc= keyinp ("input", &cmd$)
        if rc then return                     % bakkey

        con ("tag", cmd$, wg_con)           % tag cmd to ">"
        keyinp ("put", "")
        gr.render
        if cmd$="exit" then goto closekbd
        if cmd$="clear" then goto clearcmd
        gosub eliza_input

        do                                      % split long lines
           w = len(l$)
           if w <= maxchar then d_u.break
           s$=l$
           while w > maxchar
                 s$ = left$(l$, maxchar)
                 l$=mid$(l$,maxchar+1)
                 w = len(l$)
                 call con ("print", s$, wg_con)
           repeat
        until 0
        if l$<>"" then call con ("print", l$, wg_con)
        con ("print", ">", wg_con)
return
%---------------------------------------
eliza_intro:
    intro$="**************************\n" +~
           "ELIZA\n" +~
           "CREATIVE COMPUTING (1966)\n" +~
           "MORRISTOWN, NEW JERSEY\n" +~
           "\n" +~
           "ADAPTED FOR IBM PC BY\n" +~
           "PATRICIA DANIELSON AND\n" +~
           "PAUL HASHFIELD. Adapted for\n" +~
           "rfo-basic by humpty (2014).\n" +~
           "\n" +~
           "Please don't use commas\n" +~
           " or periods in inputs.\n" +~
           "*************************" +~
           "\n" +~
           "HI! I'M ELIZA.\nWHAT'S YOUR PROBLEM?\n" +~
           ">"
    con ("print", intro$, wg_con)
return
%---------------------------------------
eliza_stop:
    con ("print", "End of session. Do come again.\n>", wg_con)
return
%---------------------------------------
eliza_init:
    REM*****INITIALIZATION**********
    DIM S[36],R[36],N[36]
    DIM KEYWORD$[36],WORDIN$[7],WORDOUT$[7],REPLIES$[112]
    N1=36
    N2=14
    N3=112

    FOR X = 1 TO N1
        read.next KEYWORD$[X]
    NEXT X
    FOR X = 1 TO N2/2
        read.next WORDIN$[X]
        read.next WORDOUT$[X]
    NEXT X
    FOR X = 1 TO N3
        read.next REPLIES$[X]
    NEXT X
    FOR X=1 TO N1
        read.next S[X],L
        R[X]=S[X]
        N[X]=S[X]+L-1
    NEXT X
return
%---------------------------------------
eliza_input:
    REM ***********************************
    REM *******USER INPUT SECTION**********
    REM ***********************************
!    INPUT "HI! I'M ELIZA. WHAT'S YOUR PROBLEM?",I$
    I$= upper$(cmd$)
    I$="  "+I$+"  "
    REM GET RID OF APOSTROPHES
    FOR L=1 TO LEN(I$)
L230:
REM IF MID$(I$,L,1)="'"THEN I$=LEFT$(I$,L-1)+RIGHT$(I$,LEN(I$)-L):GOTO L230

    IF L+4>LEN(I$)THEN goto L250
    IF MID$(I$,L,4) <> "SHUT" THEN goto L250
    con ("print", "THAT'S NOT VERY NICE!",wg_con)
    return
L250:
    NEXT L
    IF I$<>P$ THEN goto L260
    l$="PLEASE DON'T REPEAT YOURSELF!"
    return
L260:
    REM ***********************************
    REM ********FIND KEYWORD IN I$*********
    REM ***********************************
    FOR K=1 TO N1
    FOR L=1 TO LEN (I$)-LEN (KEYWORD$[K])+1
    IF MID$(I$,L,LEN(KEYWORD$[K]))<>KEYWORD$[K] THEN goto L350
    IF K <> 13 THEN goto L349
    IF MID$(I$,L,LEN(KEYWORD$[29]))=KEYWORD$[29] THEN K = 29
L349:
    F$ = KEYWORD$[K]
    GOTO L390
L350:
    NEXT L
    NEXT K
    K=36
    GOTO L570     % REM WE DIDN'T FIND ANY KEYWORDS
    REM ******************************************
L390:
    REM **TAKE PART OF STRING AND CONJUGATE IT****
    REM **USING THE LIST OF STRINGS TO BE SWAPPED*
    REM ******************************************
    C$=" "+RIGHT$(I$,LEN(I$)-LEN(F$)-L+1)+" "
    FOR X=1 TO N2/2
    FOR L=1 TO LEN(C$)
    IF L+LEN(WORDIN$[X])>LEN(C$) THEN goto L510
    IF MID$(C$,L,LEN(WORDIN$[X]))<>WORDIN$[X] THEN goto L510
    C$=LEFT$(C$,L-1)+WORDOUT$[X]+RIGHT$(C$,LEN(C$)-L-LEN(WORDIN$[X])+1)
    L = L+LEN(WORDOUT$[X])
    GOTO L540
L510:
    IF L+LEN(WORDOUT$[X])>LEN(C$)THEN goto L540
    IF MID$(C$,L,LEN(WORDOUT$[X]))<>WORDOUT$[X] THEN goto L540
    C$=LEFT$(C$,L-1)+WORDIN$[X]+RIGHT$(C$,LEN(C$)-L-LEN(WORDOUT$[X])+1)
    L=L+LEN(WORDIN$[X])
L540:
    NEXT L
    NEXT X
    IF MID$(C$,2,1)=" "THEN C$=RIGHT$(C$,LEN(C$)-1) % REM ONLY 1 SPACE
    FOR L=1 TO LEN(C$)
L557:
    IF MID$(C$,L,1)<>"!" THEN goto L558
    C$=LEFT$(C$,L-1)+RIGHT$(C$,LEN(C$)-L)
    GOTO L557
L558:
    NEXT L
    REM **********************************************
L570:
    REM **NOW USING THE KEYWORD NUMBER [K] GET REPLY**
    REM **********************************************
    F$ = REPLIES$[R[K]]
    R[K]=R[K]+1
    IF R[K]>N[K] THEN R[K]=S[K]
    IF RIGHT$(F$,1)="*" THEN goto L625
    l$=F$
    P$=I$
    return
L625:
    IF C$<>"   " THEN goto L630
    l$="YOU WILL HAVE TO ELABORATE MORE FOR ME TO HELP YOU"
    return
L630:
    l$=LEFT$(F$,LEN(F$)-1)+C$
    P$=I$
    return
REM *******************************
REM *****PROGRAM DATA FOLLOWS******
REM *******************************
REM *********KEYWORDS**************
REM *******************************
read.data "CAN YOU ","CAN I ","YOU ARE ","YOU'RE ","I DON'T ","I FEEL "
read.data "WHY DON'T YOU ","WHY CAN'T I ","ARE YOU ","I CAN'T ","I AM ","I'M "
read.data "YOU ","I WANT ","WHAT ","HOW ","WHO ","WHERE ","WHEN ","WHY "
read.data "NAME ","CAUSE ","SORRY ","DREAM ","HELLO ","HI ","MAYBE "
read.data "NO","YOUR ","ALWAYS ","THINK ","ALIKE ","YES ","FRIEND "
read.data "COMPUTER", "NOKEYFOUND"
REM *********************************
REM ***STRING DATA FOR CONJUGATIONS**
REM *********************************
read.data " ARE "," AM "," WERE "," WAS "," YOU "," I "," YOUR"," MY "
read.data " I'VE "," YOU'VE "," I'M "," YOU'RE "
read.data " ME "," YOU "
REM ******************************
REM *********REPLIES**************
REM ******************************
read.data "DON'T YOU BELIEVE THAT I CAN*"
read.data "PERHAPS YOU WOULD LIKE TO BE LIKE ME*"
read.data "YOU WANT ME TO BE ABLE TO*"
read.data "PERHAPS YOU DON'T WANT TO*"
read.data "DO YOU WANT TO BE ABLE TO*"
read.data "WHAT MAKES YOU THINK I AM*"
read.data "DOES IT PLEASE YOU TO BELIEVE I AM*"
read.data "PERHAPS YOU WOULD LIKE TO BE*"
read.data "DO YOU SOMETIMES WISH YOU WERE*"
read.data "DON'T YOU REALLY*"
read.data "WHY DON'T YOU*"
read.data "DO YOU WISH TO BE ABLE TO*"
read.data "DOES THAT TROUBLE YOU*"
read.data "DO YOU OFTEN FEEL*"
read.data "DO YOU OFTEN FEEL*"
read.data "DO YOU ENJOY FEELING*"
read.data "DO YOU REALLY BELIEVE I DON'T*"
read.data "PERHAPS IN GOOD TIME I WILL*"
read.data "DO YOU WANT ME TO*"
read.data "DO YOU THINK YOU SHOULD BE ABLE TO*"
read.data "WHY CAN'T YOU*"
read.data "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM*"
read.data "WOULD YOU PREFER IF I WERE NOT*"
read.data "PERHAPS IN YOUR FANTASIES I AM*"
read.data "HOW DO YOU KNOW YOU CAN'T*"
read.data "HAVE YOU TRIED?"
read.data "PERHAPS YOU CAN NOW*"
read.data "DID YOU COME TO ME BECAUSE YOU ARE*"
read.data "HOW LONG HAVE YOU BEEN*"
read.data "DO YOU BELIEVE IT IS NORMAL TO BE*"
read.data "DO YOU ENJOY BEING*"
read.data "WE WERE DISCUSSING YOU--NOT ME."
read.data "OH, I*"
read.data "YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?"
read.data "WHAT WOULD IT MEAN TO YOU IF YOU GOT*"
read.data "WHY DO YOU WANT*"
read.data "SUPPOSE YOU SOON GOT*"
read.data "WHAT IF YOU NEVER GOT*"
read.data "I SOMETIMES ALSO WANT*"
read.data "WHY DO YOU ASK?"
read.data "DOES THAT QUESTION INTEREST YOU?"
read.data "WHAT ANSWER WOULD PLEASE YOU THE MOST?"
read.data "WHAT DO YOU THINK?"
read.data "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?"
read.data "WHAT IS IT THAT YOU REALLY WANT TO KNOW?"
read.data "HAVE YOU ASKED ANYONE ELSE?"
read.data "HAVE YOU ASKED SUCH QUESTIONS BEFORE?"
read.data "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?"
read.data "NAMES DON'T INTEREST ME."
read.data "I DON'T CARE ABOUT NAMES --PLEASE GO ON."
read.data "IS THAT THE REAL REASON?"
read.data "DON'T ANY OTHER REASONS COME TO MIND?"
read.data "DOES THAT REASON EXPLAIN ANYTHING ELSE?"
read.data "WHAT OTHER REASONS MIGHT THERE BE?"
read.data "PLEASE DON'T APOLOGIZE!"
read.data "APOLOGIES ARE NOT NECESSARY."
read.data "WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE?"
read.data "DON'T BE SO DEFENSIVE!"
read.data "WHAT DOES THAT DREAM SUGGEST TO YOU?"
read.data "DO YOU DREAM OFTEN?"
read.data "WHAT PERSONS APPEAR IN YOUR DREAMS?"
read.data "ARE YOU DISTURBED BY YOUR DREAMS?"
read.data "HOW DO YOU DO ...PLEASE STATE YOUR PROBLEM."
read.data "YOU DON'T SEEM QUITE CERTAIN."
read.data "WHY THE UNCERTAIN TONE?"
read.data "CAN'T YOU BE MORE POSITIVE?"
read.data "YOU AREN'T SURE?"
read.data "DON'T YOU KNOW?"
read.data "ARE YOU SAYING NO JUST TO BE NEGATIVE?"
read.data "YOU ARE BEING A BIT NEGATIVE."
read.data "WHY NOT?"
read.data "ARE YOU SURE?"
read.data "WHY NO?"
read.data "WHY ARE YOU CONCERNED ABOUT MY*"
read.data "WHAT ABOUT YOUR OWN*"
read.data "CAN YOU THINK OF A SPECIFIC EXAMPLE?"
read.data "WHEN?"
read.data "WHAT ARE YOU THINKING OF?"
read.data "REALLY, ALWAYS?"
read.data "DO YOU REALLY THINK SO?"
read.data "BUT YOU ARE NOT SURE YOU*"
read.data "DO YOU DOUBT YOU*"
read.data "IN WHAT WAY?"
read.data "WHAT RESEMBLANCE DO YOU SEE?"
read.data "WHAT DOES THE SIMILARITY SUGGEST TO YOU?"
read.data "WHAT OTHER CONNECTIONS DO YOU SEE?"
read.data "COULD THERE REALLY BE SOME CONNECTION?"
read.data "HOW?"
read.data "YOU SEEM QUITE POSITIVE."
read.data "ARE YOU SURE?"
read.data "I SEE."
read.data "I UNDERSTAND."
read.data "WHY DO YOU BRING UP THE TOPIC OF FRIENDS?"
read.data "DO YOUR FRIENDS WORRY YOU?"
read.data "DO YOUR FRIENDS PICK ON YOU?"
read.data "ARE YOU SURE YOU HAVE ANY FRIENDS?"
read.data "DO YOU IMPOSE ON YOUR FRIENDS?"
read.data "PERHAPS YOUR LOVE FOR FRIENDS WORRIES YOU."
read.data "DO COMPUTERS WORRY YOU?"
read.data "ARE YOU TALKING ABOUT ME IN PARTICULAR?"
read.data "ARE YOU FRIGHTENED BY MACHINES?"
read.data "WHY DO YOU MENTION COMPUTERS?"
read.data "WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?"
read.data "DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?"
read.data "WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?"
read.data "SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?"
read.data "WHAT DOES THAT SUGGEST TO YOU?"
read.data "I SEE."
read.data "I'M NOT SURE I UNDERSTAND YOU FULLY."
read.data "COME COME ELUCIDATE YOUR THOUGHTS."
read.data "CAN YOU ELABORATE ON THAT?"
read.data "THAT IS QUITE INTERESTING."
REM *************************
REM *****DATA FOR FINDING RIGHT REPLIES
REM *************************
read.data 1,3,4,2,6,4,6,4,10,4,14,3,17,3,20,2,22,3,25,3
read.data 28,4,28,4,32,3,35,5,40,9,40,9,40,9,40,9,40,9,40,9
read.data 49,2,51,4,55,4,59,4,63,1,63,1,64,5,69,5,74,2,76,4
read.data 80,3,83,7,90,3,93,6,99,7,106,6
