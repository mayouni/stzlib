

o1 = new MyString("ring")

o1 {
	? Content()
	#--> "ring"

	Uppercase()

	? Content()
	#--> RING

}

? o1.LowercaseQ().Content()
? o1.Uppercased()
? o1.Content()

class MyString
	@cContent

	def init(cStr)
		@cContent = cStr

	def Content()
		return @cContent

	def Copy()
		return new MyString(@cContent)

	def Uppercase()
		@cContent = upper(@cContent)

		def UppercaseQ()
			This.Uppercase()
			return This
	def Uppercased()
		cResult = This.Copy().UppercaseQ().Content()
		return cResult

	def Lowercase()
		@cContent = lower(@cContent)

		def LowercaseQ()
			This.Lowercase()
			return This

	def Lowercased()
		cResult = This.Copy().LowrcaseQ().Content()
		return cResult

