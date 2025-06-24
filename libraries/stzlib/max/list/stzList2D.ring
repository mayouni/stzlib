

func StzList2D(paList)
	return new stzList2D(paList)

	func StzList2DQ(paList)
		return new stzList2D(paList)

	func Stz2DList(paList)
		return new stzList2D(paList)

	func Stz2DListQ(paList)
		return new stzList2D(paList)


class stz2DList from stzList2D

class stzList2D from stzListOfLists

	def init(paList)

		if NOT (isList(paList) and @IsListOfLists(paList))
			StzRaise("Can't create the stz2DList object! paList must be a list of lists.")
		ok

		nLen = len(paList)
		nLen1 = len(paList[1])

		for i = 2 to nLen
			if len(paList[i]) != nLen1
				StzRaise("Can't create the stz2DList object! All the lists must have same size.")
			ok
		next

		This.@aContent = paList

		def List2D()
			return super.Content()
