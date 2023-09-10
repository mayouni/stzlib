
# Used, in particular, to enable chains of truth, like
# when we make multiple equality check :

# ? Q(2+5) = Q(3+4) = Q(9-2) = 7
#--> TRUE

func StzFalseObjectQ()
	return new stzFalseObject

#< @ClassAlternativeForms

class stzFalsObject from stzFalseObject
class stzFlaseObject from stzFalseObject

#>

class stzFalseObject

	def Where(pcCondition)
		return FALSE

		def W(pcCondition)
			return FALSE

	def IsEqualToCSQ(p, pCaseSensitie)
		return This

		def IsEqualToQ(p)
			return This

	def IsEqualToCS(p, pCaseSensitive)
		return FALSE

		def ISEqualTo(p)
			return FALSE
