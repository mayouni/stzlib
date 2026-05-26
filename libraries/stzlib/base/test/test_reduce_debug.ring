load "../stzBase.ring"

# Debug Reduce step by step

# Step 1: Create list and marshal to engine
o = new stzList([1, 2, 3, 4, 5])
? "List created with " + len(o.Content()) + " items"

# Step 2: Test Map first (uses same engine list + expression eval)
aMapped = o.Map('{ @item * 2 }')
? "Map result count: " + len(aMapped)
for _mdi = 1 to len(aMapped)
	? "  Map[" + _mdi + "] = " + aMapped[_mdi]
next

# Step 3: Test Filter (uses same expression eval)
aFiltered = o.Filter('{ @item > 3 }')
? "Filter result count: " + len(aFiltered)

# Step 4: Test CountW
nCount = o.CountW('{ @item > 2 }')
? "CountW > 2: " + nCount

# Step 5: Direct engine reduce call
? ""
? "--- Direct engine reduce test ---"
pList = StzEngineMarshalList([1, 2, 3, 4, 5])
? "Engine list handle: " + isNULL(pList)

# Create init value
pInit = StzEngineValueNewInt(0)
? "Init value type: " + StzEngineValueType(pInit)
? "Init value int: " + StzEngineValueGetInt(pInit)

# Call reduce with stripped expression
pResult = StzEngineListReduceExpr(pList, "@value + @item", pInit)
? "Result is NULL: " + isNULL(pResult)
if not isNULL(pResult)
	? "Result type: " + StzEngineValueType(pResult)
	nType = StzEngineValueType(pResult)
	if nType = 2
		? "Result int: " + StzEngineValueGetInt(pResult)
	but nType = 3
		? "Result float: " + StzEngineValueGetFloat(pResult)
	ok
	StzEngineValueFree(pResult)
ok

StzEngineValueFree(pInit)
StzEngineListFree(pList)

# Step 6: Now test the Reduce method
? ""
? "--- Reduce method test ---"
nSum = o.Reduce('{ @value + @item }', 0)
? "Reduce sum: " + nSum
? "Type: " + type(nSum)
