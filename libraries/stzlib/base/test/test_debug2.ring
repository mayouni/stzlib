load "../stzBase.ring"

# Debug Contains fix
o = new stzList([5, 3, 8, 1, 9])
? "Contains(3) = " + o.Contains(3)
? "Contains(5) = " + o.Contains(5)
? "Find(3) = " + o.Find(3)

# Debug Reduce - try different approaches
oFunc = new stzList([1, 2, 3, 4, 5])

# Test Map first to make sure engine expressions work
aMapped = oFunc.Map('{ @item * 2 }')
? "Map result: " + len(aMapped) + " items"
if len(aMapped) > 0
	? "  First: " + aMapped[1]
ok

# Test Filter
aFiltered = oFunc.Filter('{ @item > 3 }')
? "Filter result: " + len(aFiltered) + " items"

# Test CountW
nCount = oFunc.CountW('{ @item > 2 }')
? "CountW > 2: " + nCount

# Test Reduce with simple sum
nSum = oFunc.Reduce('{ @value + @item }', 0)
? "Reduce sum: " + nSum
? "Type: " + type(nSum)

# Test ReduceNoInit
nSum2 = oFunc.ReduceNoInit('{ @value + @item }')
? "ReduceNoInit sum: " + nSum2
