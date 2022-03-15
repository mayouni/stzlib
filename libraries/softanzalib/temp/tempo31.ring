load "softanzaLib.ring"
cFile = read("tempo31.ring")
//? cFile

o1 = new Person { name = "Mansour" age = 45 }
o2 = new Person { name = "Mastra" age = 32 }
o3 = new Thing { name = "Thingza" price = 1200 }

aList = [ 5, 2, o1, 3, o2, o3 ]
? stzlist2code(:aList, read("tempo31.ring"))

func stzList2Code(aList,cFileCode)
//? cFileCode
	oFileCode = new stzString(cFileCode)
? oFileCode.Content()
	nStart = oFileCode.FindLast("aList =")

	bLastCaract = FALSE
	i = nStart-1
	n = 0
	cResult = oFileCode.Section(nStart, 10)
	cResult = substr(cFileCode,nStart, 10)

/*
	while NOT bLastCaract
		i++
		if cFileCode[i] = "["
			n++
		but cFileCode[i] = "]"
			n--
			if n = 0 { bLastCaract = TRUE }
		ok

		cResult += cFileCode[i]	
	end
*/
	//return cResult
	
/*
? FindObject(:o2, aList)

class FindObject(pcObjectName, paList)
	oListStringified = new stzString( list2str(paList) )
	if oListStringified.Contains(pcObjectName, :CaseSensitive = FALSE)
		return TRUE
	else
		return FALSE
	ok
*/
class Person
	name
	age

class Thing
	name
	price
