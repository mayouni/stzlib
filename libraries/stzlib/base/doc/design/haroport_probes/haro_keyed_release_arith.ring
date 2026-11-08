o = new K
? o.Joint([ 1, 1, 2, 2 ], [ 1, 1, 2, 2 ])
? "done"
class K
	def Joint(anA, anB)
		aAt = []
		anN = []
		nTotal = len(anA)
		for i = 1 to nTotal
			cPair = "" + (anA[i] * 3 + anB[i])
			nAt = aAt[cPair]
			if isNumber(nAt)
				anN[nAt]++
			else
				anN + 1
				aAt[cPair] = len(anN)
			ok
		next
		return anN
