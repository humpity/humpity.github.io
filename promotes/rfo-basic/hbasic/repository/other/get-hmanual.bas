!!
    Utility to 
        Download
    or
        Extract
    or
        View
    the hBasic Manual.

    v1.00 - humpty Sep 2024
!!
Menu:

Dialog.message "hManual"~
    ,"Choose a task. BackKey to quit.", task , "Download", "Extract", "View"
if task = 0 then goto abort

if task <> 1 then goto Extract
    ? "downloading.."
    url$ = "https://humpity.github.io/promotes/rfo-basic/hbasic/repository/hmanual.zip"
    byte.open r,fv,url$
    if r = -1 then goto abort
    byte.copy fv,"hmanual.zip"
    ? "downloaded."
    goto Menu
Extract:
if task <> 2 then goto View
    file.mkdir ok,"hmanual"
    if !ok then goto abort

    ? "unzipping.."
    file.exists ok,"hmanual.zip"
    if !ok then ? "zip file not in data/":goto abort
    Zip.dir "hmanual.zip", a$[], "/"
    zip.open r,fz,"hmanual.zip"

    base$="hmanual/"
    array.length z,a$[]
    for i=1 to z
        f$=a$[i]
    %   ? f$    % debug
        if ends_with("/",f$) then f_n.continue

        d=is_in ("/",f$,-1) % sub dir ?
        if d then
            d$ = left$(f$,d)
            file.mkdir ok,base$+d$
    %       if !ok then ?" mkdir not ok"
        endif

        byte.open w,fout,base$+f$
        zip.read fz, buff$, f$
        byte.write.buffer fout,buff$
    next
    ? "extracted."
    goto Menu
View:
    html.open
    html.load.url "hmanual/index.html"
    DO
        DO : HTML.GET.DATALINK data$ : UNTIL data$ <> ""
        type$ = LEFT$(data$, 4)        % get type
        data$ = MID$(data$,5)         % get data

        sw.begin type$
        sw.case "LNK:"                % link tapped
            html.load.url data$     % load the new URL
            d_u.continue
        sw.case "ERR:"
            ? "Error "; data$
            d_u.break
        sw.case "BAK:"                % backKey 0=first page
            if data$="0" then d_u.break else HTML.go.back
            sw.break
        sw.end
        % ignore other types..
    UNTIL 0
    html.close
    goto Menu
end
abort:
? "aborted"
end
