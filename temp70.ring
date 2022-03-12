load "stzlib.ring"


aList = [ 2, 7, 10 ]
o1 = new stzList(aList)
? o1.WalkUntil("Item = 7")
? o1.WalkUntilItem(7)

? aList
