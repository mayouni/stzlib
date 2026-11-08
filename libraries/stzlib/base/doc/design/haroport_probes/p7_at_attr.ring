o = new Counter
o.Bump()
? "attr after Bump: " + o.@nCount
class Counter
	@nCount = 1
	def Bump()
		ncount = 99
		return ncount
