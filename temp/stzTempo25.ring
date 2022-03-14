Load "SoftanzaLib.ring"

o1 = new Person
? o1.IsEqualTo(:o1)

// GO BACK TO SUPPROTING LISTS IN find --> IsEqualTo --> HasSameContentAs
//o1 = 	new stzList([ 3, o3, 3, o3, "A", 2, "Z", "C", o3, "A", [2,5],[2,5] ])
o2 = new stzList([ "A", "T", "B", 5, "C", "A", "A", "D", "E", o1, o1, "D" , o1])

? o2.FindAll(o1) // CORRECT THIS!!!
//? o1.FindFirst([5,6]) // CORRECT THIS!!!

//? o1.WalkUntilItem("T")

/*
? o1.NumberOfOccurrenceOf("A")
? o1.Findfirst("A")
? o1.RemoveDuplicates()
? o1.Index()
/*
? o1.ItemsHaveSameOrderAs(  [ 3, o2, "A", 2, "Z", "C" ])
? o1.SortInAscending()
? o1.IsEqualTo([ 3, o2, "A", 2, "Z", "C" ])
*/
class Person from stzObject
	

/*
o1 {
	//AddWalker( Named(:Walker1), StartingAt(1), EndingAt(10), NStepsATime(4) )
	//AddWalker( :Walker2, 6, 10,   [ :NStepsATime , 3 ] )
	AddWalker( Named(:Walk1), StartingAt(1), EndingAt(12), TakingNEqualMoves(3) )
	AddWalker( Named(:Walk1), StartingAt(1), EndingAt(15), TakingNMoves(3) )

	? Yield( InfoAbout(:Position), WhileWalking(:Walk1) )

	Perform( Action(:LowCase), WhileWalking(:Walk1) )
	? Content()

}


func WhileWalking(c)
	return c

func Named(c)
	return c
func StartingAt(n)
	return n

func EndingAt(n)
	return n

func NStepsATime(n)
	return [ :NStepsATime , n ]

func TakingNMoves(n)
	return [ :TakingNMoves , n ]

func TakingNEqualMoves(n)
	return [ :TakingNEqualMoves , n ]

func InNRandomSteps(n)
	return [ :InNSteps , n ]

func NMoreStepsATime(n)
	return [ :NMoreStepsATime , n ]

func FellowingNSteps(paSteps)
	return [ :FellowingNSteps , paSteps ]

func FellowingRandomNSteps(paSteps)
	return [ :FellowingRandomNSteps , paSteps ]

func Action(c)
	return c

func InfoAbout(c)
	return c

func Show(i)
	? Content[i]


class zList
	aContent = []
	oWalkers = new zWalkerList

	def init(a)
		aContent = a

	def Content()
		return aContent

	def AddWalker(pcName, pnStart, pnEnd, paStepping)
		oTemp = new zWalker(pnStart, pnEnd, paStepping)
		oWalkers.AddWalker(pcName, oTemp)

	def Walkers()
		return oWalkers.Content()

	def Walker(pcWalker)
		return Walkers()[pcWalker].Content()

	def Perform(pcMethod, pcWalker)
		try
			for i = 1 to len( Walker(pcWalker) )
				cCode = "Content()[" + i + "] = " + pcMethod + "(" + Walker(pcWalker)[i] + ")"
				eval( cCode )
			next i
			return TRUE
		catch
			return FALSE
		done

	def Yield(pcMethod, pcWalker)
		aResult = []
		for i = 1 to len( Walker(pcWalker) )
			cCode = "aResult + " + pcMethod + "(" + Walker(pcWalker)[i] + ")"
			eval( cCode )
		next i
		return aResult

	def Item(n)
		return Content()[n]

	def Position(n)
		return n

	def ShowItem(n)
		? Item(n)

	def LowCase(n)
		return lower(Item(n))


class zWalker
	nStartpoint
	nEndpoint

	NStepsATime

	NMoves

	NRandomSteps
	NMoreStepsATime
	FellowingNSteps
	FellowingRandomNSteps

	aVisitedPoints = []
	aSkippedPoints = []

	def init(pnStartPoint, pnEndPoint, paStepping)
		nStartPoint = pnStartPoint
		nEndPoint = pnEndPoint

		switch paStepping[1]
		on :NStepsATime
			NStepsATime = paStepping[2]

			for i = pnStartPoint to pnEndPoint step NStepsATime
				aVisitedPoints + i
			next	
			
		on :TakingNEqualMoves
			NMoves = paStepping[2]
			nInterpoints = pnEndPoint - 1
			
			NStepsATime = IntegerPart(nInterpoints / nMoves)
	
			for i = pnStartPoint to pnEndPoint step NStepsATime
				aVisitedPoints + i
			next

		on :TakingNMoves
			NMoves = paStepping[2]
			nInterpoints = pnEndPoint - 1
			
			NStepsATime = IntegerPart(nInterpoints / nMoves)
	
			for i = pnStartPoint to pnEndPoint step NStepsATime
				aVisitedPoints + i
			next

			//aVisitedPoints = UpdateLastItem(aVisitedPoints, pnEndPoint)
			aVisitedPoints[ len(aVisitedPoints) ] = pnEndPoint
	
		on :InNRandomSteps

		off

	def Content()
		return aVisitedPoints

class zWalkerList
	aContent = []

	def AddWalker(pcName, poWalker)
		aContent + [ pcName, poWalker ] # TODO: pcName must be unique

	def Content()
		return aContent

