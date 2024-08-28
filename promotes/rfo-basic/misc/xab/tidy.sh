# if called from elsewhere, make sure we start here
ME=`readlink -f $0`; MYDIR=`dirname $ME`; cd $MYDIR

tidy -mqiu *.htm
tidy -mqiu *.html
