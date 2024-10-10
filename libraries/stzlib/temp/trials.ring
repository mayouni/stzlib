load "stdlib.ring"
load "qtcore.ring"

cStr = " line1 line1 line1 
line2 line2 line2
line3 line3 line3"

# split with ring

? split(cStr, nl)

# split with qt

? "---" + nl

oQStr = new QString2()
oQStr.append(cStr)

oQStrList = oQStr.split(NL, 0, 0)

acResult = []
for i = 0 to oQStrList.size()-1
	acResult + oQStrList.at(i)	
next

? acResult
