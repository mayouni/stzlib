o = new K
? o.Ids([ "a", "a", "b", "b" ])
? "done"
class K
	def Ids(aData)
		aSeen = []
		anCounts = []
		nLen = len(aData)
		for i = 1 to nLen
			cKey = "" + aData[i]
			nId = aSeen[cKey]
			if isNumber(nId)
				anCounts[nId]++
			else
				anCounts + 1
				nId = len(anCounts)
				aSeen[cKey] = nId
			ok
		next
		return anCounts
