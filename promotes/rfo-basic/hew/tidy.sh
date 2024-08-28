# if called from elsewhere, make sure we start here
ME=`readlink -f $0`; MYDIR=`dirname $ME`; cd $MYDIR

tidy -mqiu --quote-ampersand 0 --drop-proprietary-attributes 1 *.htm
tidy -mqiu --quote-ampersand 0 --drop-proprietary-attributes 1 *.html
