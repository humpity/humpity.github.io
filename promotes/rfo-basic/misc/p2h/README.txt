p2h
---
p2h converts the BASIC! pdf manual to separate html files for each page.

	* Uses pdftohtml for conversion.
	* Inserts floating navigation buttons for each page.
	* Replaces redundant blank background pngs with white.
	* Changes font to Arial

	Excluded dependencies;
	linux : ghostscript
	windows : (all included)

Usage: 	p2h <filename.pdf>
	run from command line in same directory.

Output: to sub directory [output]

p2hgui
------
p2hgui is a Gui for p2h.

	* Offers downloading manual from url to download.pdf.

	Excluded dependencies;
	linux : libfltk1.3, wget
	windows (all included)

License & Acknowledgements
--------------------------
p2h and p2hgui
	Freeware (by humpty 2016).
	Other parts are covered by their own licenses, these are;
pdftohtml
	http://pdftohtml.sourceforge.net/
	GNU GPLv2  -Derek Noonburg
ghostscipt
	http://www.ghostscript.com/
	GNU Affero AGPL - Artifex Software Inc.
wget
	http://www.gnu.org/software/wget/
	GNU GPL - Hrvoje Nikšić..Giuseppe Scrivano
openssl
	http://www.openssl.org/
	Apache License 1.0 and four-clause BSD License
FLTK
	Gui Built with fltk.
	www.fltk.org
