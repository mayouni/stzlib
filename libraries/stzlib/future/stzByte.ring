
func StzByte(aByte)
	return new stzByte(aByte)

func StzByteQ(aByte)
	return new stzByte(aByte)

func IsListOfBits(paList)
	oList = new stzListOfNumbers(paList)
	if oList.IsListOfBits()
		return 1
	else
		return 0
	ok

	func @IsListOfBits()
		return IsListOfBits(paList)

class stzByte from stzObject
	aByte

	def init(a8Bits)
		if IsListOfBits(a8Bits)
			for i = 1 to 8
				aByte + a8Bits[i]
			next i
		else
			StzRaise(stzByteError(:CanNotCreateTheByte))
		ok
