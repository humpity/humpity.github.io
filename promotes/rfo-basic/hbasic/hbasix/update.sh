# if called from elsewhere, make sure we start here
ME=`readlink -f $0`; MYDIR=`dirname $ME`; cd $MYDIR

echo deleting old file..
rm -f ../repository/other/manual-x.zip_file

echo creating the manual-x zip file..
zip -r -FS ../repository/other/manual-x.zip_file manual-x -x \*.sh

cd ../repository/other

echo renaming all apk to apk_file
rename -f 's/\.apk$/\.apk_file/' *.apk

echo creating index.html..
tree -h -H '.' -L 1 -C -I "pics|*.sh|*.css|*.html" -T "${PWD##*/}" --dirsfirst --noreport --charset utf-8 -o index.html

# change dirs to force open their indexes
sed -i 's:<br>:\n_M_A_R_K_E_R_:g' index.html
# this does not work anymore (what happened to sed ??
# sed -i 's:\"DIR\" href\=\"\..*\/[^a]:&REPLACED:g' index.html
# --------------------------
# use this instead
sed -i 's:"DIR" href="\..*/":&REPLACED:g' index.html
sed -i 's:"REPLACED:index.html":g' index.html

sed -i 's:\.VERSION.*;:& color\:grey;:g' index.html
sed -i 's:by Kyosuke Tokoro:&<br>Dir-links @2020 by humpty <SCRIPT type="text/javascript" src="https\://humpty\.drivehq\.com/counter\.js"></SCRIPT>:g' index.html
sed -i ':a;N;$!ba;s/\n_M_A_R_K_E_R_/<br>/g' index.html

# change . to open parent's main page
echo creating parent link
sed -i 's|href="./index.html">.<|href="../index.html">..<|' index.html



