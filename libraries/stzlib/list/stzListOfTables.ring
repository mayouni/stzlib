// TODO

func IsListOfTables(paList)

	if NOT (isList(paList) and IsListOfHashTables(paList))
		return FALSE
	ok

	nRows = len(paList[1][2])
	nLen = len(paList)

	for i = 1 to nLen
		if len(paList[i][2]) != nRows
			return FALSE
		ok
	next

	return TRUE

class stzListOfTables from stzListOfHashLists
	@aContent = []

