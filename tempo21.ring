load "softanzalib.ring"
o1 = new Thing { Content = "Something1" }
o2 = new Thing { Content = "Something2" }

aList = [ 10, 20, "Sfax", "Gafsa", 30, o1, o2, "Tunis", 1:3 ]
? types()


func Types()
	aResult = []
	for item in aList
		if find(aResult, type(item)) = 0
			aResult + type(item)
		ok
	next
	return aResult

func ItemsByType()
	aResult = []
	aTypes = Types()

	for item in aTypes
		aResult + [ item, [] ]
	next

	for item in aList
		i = find(aTypes,type(item))
		aResult[i][2] + item
	next
	return aResult


class Thing
	content 
