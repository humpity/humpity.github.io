p$="com.rfo.basic"		% package name
path$ = "/data/data/"+p$+"/"
system.open
system.write "cd "+ path$+" 2>&1"
pause 50

b$="main"			% binary name
file.root datapath$		% <base>/data
srce$ = datapath$+"/"+b$
system.write ("cat "+srce$+" >./"+b$+" 2>&1")

system.write "chmod 777 "+b$+" 2>&1"	% make executable

system.write "./"+b$+" 2>&1"		% execute binary

r$=""				% assume no reponse
pause 100
system.READ.READY ready		% if response
while ready
      system.READ.LINE l$
      r$ += l$+"\n"
      system.READ.READY ready
repeat
print r$			% output

onBackKey:
	system.close
	system.open
	system.write "cd "+ path$ + ";rm "+b$   % delete the binary
	pause 100
	system.close
end
