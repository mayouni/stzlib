load "../stzBase.ring"

# Debug Contains with number
o = new stzList([5, 3, 8, 1, 9])
? "Contains(3) = " + o.Contains(3)
? "Type of Contains result: " + type(o.Contains(3))

# Debug Reduce
oFunc = new stzList([1, 2, 3, 4, 5])
nSum = oFunc.Reduce('{ @value + @item }', 0)
? "Reduce sum = " + nSum
? "Type: " + type(nSum)
? "nSum = 15? " + (nSum = 15)
? "nSum = 15.0? " + (nSum = 15.0)
