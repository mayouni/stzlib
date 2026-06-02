load "../stzBase.ring"

oStr = new stzString("one;two,three:four")
pH = oStr.Engine()

nCount = StzEngineStringRegexSplitCount(pH, "[;,:]", 0)
? "Engine split count: " + nCount

for i = 0 to nCount
	cPart = StzEngineStringRegexSplitGet(pH, "[;,:]", 0, i)
	? "  idx " + i + " = [" + cPart + "]"
next
