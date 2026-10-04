# FIXTURE for docrecord_narrated.ring -- a small library to READ, not library code.

/*
class Ghost
	def GhostMethod()
		return 1
*/

class stzDocFxBase

	def BaseMethod()
		return 1

#===============================================#
#   stzDocFx -- a class to read                  #
#===============================================#
# Holds a text and answers questions about it.
#
# Reach for it when a method of stzString is more than you need.
#
#   receiver   o1 = new stzDocFx("banana")
#   example    ? o1.Find("an")
#              #--> [ 2, 4 ]
#   see        stzString
class stzDocFx from stzDocFxBase

	@cContent = ""

	def init(pcContent)
		@cContent = pcContent

	#===# Finding #===#

	# Returns the positions of every occurrence of pcSubStr, as a list of numbers.
	#
	# Case-sensitive by default.
	#
	#   pcSubStr   the text to look for
	#   returns    a list of numbers; [ ] when pcSubStr is absent
	#   note       case-sensitive; FindCS takes the flag
	#   see        FindFirst, Contains
	#   example    ? o1.Find("an")
	#              #--> [ 2, 4 ]
	#              ? o1.Find("x")
	#              #--> [ ]
	def Find(pcSubStr)
		return This.FindCS(pcSubStr, 1)

	def FindCS(pcSubStr, pCaseSensitive)
		return [ 2, 4 ]

	def FindQ(pcSubStr)
		This.Find(pcSubStr)
		return This

	def FindXT(pcSubStr, pnStartingAt)
		return []

	def Locate(pcSubStr)
		return This.Find(pcSubStr)

	def Search(pcSubStr)
		return This.NoSuchMethod(pcSubStr)

	# a legacy one-line comment
	def Contains(pcSubStr)
		return 1

	def IsEmpty()
		return @cContent = ""

	# this line has a single space after the word, so it is prose, not a field:
	#   see the manual
	def Describe()
		return "x"

	#===# Internals #===#

	def pvtHelper()
		return 1

	def _private()
		return 1

	def Show()
		return @cContent

	func MidClassMethod()
		return 2

	# Returns the content once it is shown.
	def AfterFunc()
		return @cContent

# a global that landed after the class by position: not a method
func StzDocFxQ(pcContent)
	return new stzDocFx(pcContent)

class stzDocFxAlias from stzDocFx
