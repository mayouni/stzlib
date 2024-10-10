//load "stdlib.ring"
load "qtcore.ring"

cStr = " line1 line1 line1 
line2 line2 line2
line3 line3 line3"

# split with ring

? StzSplit(cStr, nl)

# split with qt

? "---" + nl

func StzSplitCS(cStr, cSubStr, bCaseSensitive)
	oQStr = new QString2()
	oQStr.append(cStr)
	
	oQStrList = oQStr.split(cSubStr, 0, bCaseSensitive)
	
	acResult = []
	for i = 0 to oQStrList.size()-1
		acResult + oQStrList.at(i)	
	next

	return acResult

func StzSplit(cStr, cSubStr)
	return StzSplitCS(cStr, cSubStr, 0)
