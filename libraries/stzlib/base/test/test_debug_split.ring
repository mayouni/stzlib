load "../stzBase.ring"

oSplit = new stzStringSplitter("one;two,three:four")
aParts = oSplit.SplitByRegex("[;,:]")
? "Parts count: " + len(aParts)
for i = 1 to len(aParts)
	? "[" + i + "] = [" + aParts[i] + "]"
next
