o = new Child
o.Bump()
? "inherited attr after Bump: " + o.nCount
class Parent
	nCount = 1
class Child from Parent
	def Bump()
		ncount = 99
