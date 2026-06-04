# Narrative
# --------
# 01 Yielder Basics
#
# Extracted from stzYielderTest.ring (single-block file; no
# /*--- delimiters in the original, so body kept as one).

load "../../stzBase.ring"
? "=== stzYielder Tests ==="

# Test Map operations
oY = new stzYielder([1, -2, 3, -4, 5])

aAbs = oY.Map(:Abs)
? "Map(:Abs) = " + list2str(aAbs)
# Expected: [1, 2, 3, 4, 5]

aNeg = oY.Map(:Negate)
? "Map(:Negate) = " + list2str(aNeg)
# Expected: [-1, 2, -3, 4, -5]

aDbl = oY.Map(:Double)
? "Map(:Double) = " + list2str(aDbl)
# Expected: [2, -4, 6, -8, 10]

aSqr = oY.Map(:Square)
? "Map(:Square) = " + list2str(aSqr)
# Expected: [1, 4, 9, 16, 25]

# Test Filter operations
aPos = oY.Filter(:IsPositive)
? "Filter(:IsPositive) = " + list2str(aPos)
# Expected: [1, 3, 5]

aNegF = oY.Filter(:IsNegative)
? "Filter(:IsNegative) = " + list2str(aNegF)
# Expected: [-2, -4]

aEvn = oY.Filter(:IsEven)
? "Filter(:IsEven) = " + list2str(aEvn)
# Expected: [-2, -4]

aOdd = oY.Filter(:IsOdd)
? "Filter(:IsOdd) = " + list2str(aOdd)
# Expected: [1, 3, 5]

# Test Reduce operations
nSum = oY.Reduce(:Sum)
? "Reduce(:Sum) = " + nSum
# Expected: 3

nProd = oY.Reduce(:Product)
? "Reduce(:Product) = " + nProd
# Expected: 120

nMin = oY.Reduce(:Min)
? "Reduce(:Min) = " + nMin
# Expected: -4

nMax = oY.Reduce(:Max)
? "Reduce(:Max) = " + nMax
# Expected: 5

nCount = oY.Reduce(:Count)
? "Reduce(:Count) = " + nCount
# Expected: 5

# Test FilterMap (filter then transform)
aFM = oY.MapFiltered(:IsPositive, :Square)
? "MapFiltered(:IsPositive, :Square) = " + list2str(aFM)
# Expected: [1, 9, 25]

# Test CountWhere
nPosCount = oY.CountWhere(:IsPositive)
? "CountWhere(:IsPositive) = " + nPosCount
# Expected: 3

nNegCount = oY.CountWhere(:IsNegative)
? "CountWhere(:IsNegative) = " + nNegCount
# Expected: 2

# Test convenience methods
? "Sum() = " + oY.Sum()
? "Product() = " + oY.Product()
? "MinValue() = " + oY.MinValue()
? "MaxValue() = " + oY.MaxValue()

# Test with strings
oYS = new stzYielder(["hello", "WORLD", "  mixed  "])
aUp = oYS.Map(:StrUpper)
? "Map(:StrUpper) = " + list2str(aUp)

aLow = oYS.Map(:StrLower)
? "Map(:StrLower) = " + list2str(aLow)

aTrim = oYS.Map(:StrTrim)
? "Map(:StrTrim) = " + list2str(aTrim)

# Test ReduceConcat
oYC = new stzYielder(["a", "b", "c"])
cConcat = oYC.ReduceConcat("-")
? "ReduceConcat('-') = " + cConcat
# Expected: "a-b-c"

? ""
? "=== All stzYielder tests completed ==="

func list2str(aList)
	_cRes_ = "["
	_nListLen_ = ring_len(aList)
	for _i_ = 1 to _nListLen_
		if _i_ > 1 _cRes_ += ", " ok
		if isString(aList[_i_])
			_cRes_ += '"' + aList[_i_] + '"'
		else
			_cRes_ += "" + aList[_i_]
		ok
	next
	_cRes_ += "]"
	return _cRes_
