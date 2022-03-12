load "SoftanzaLib.ring"
/*
aWalk1 = [ 2, 5, 7 ]
o1 = new stzList( 1 : 10 )
? o1.Yield("Item >= 5 and Item <= 8 and isPrime(Item)")
? o1.Yield(:All)
? o1.Yield(aWalk1)

o1 = new stzList([ "Mahmoud", 18, "Mansour", 11, "Ahmed", 14 ])
? o1.ApplyCode("nEachNumber * 2", :ToRingNumbers)
? o1.ApplyCode("UPPER(cEachString)", :ToRingStrings)                          
*/

/*
o1 = new stzList([ "Mahmoud", ["Tea", "Coke"], "Mansour", ["Ice","Cream", "Tea"] ])
? o1.ApplyCode('find(aEachList,"Tea")', :ToRingLists)

o1 = new stzList([ 1, new Person("Mansour") , 2, new Animal("King"), 3, new Thing("Pizza") ])
? o1.ApplyCode("classname(oEachObject)", :ToRingObjects)

class Person name def init(pName) name = pName
class Animal name def init(pName) name = pName
class Thing name def init(pName) name = pName
*/

/*
o1 = new stzListOfNumbers([ 20, 18, 20, 20 ])
? o1.Mean()
? o1.MeanByCoefficient([  4,  1,  4,  1 ])
*/

/*
a1 = [ "A", "B", "C", "A", "C" ]
o1 = new stzList(a1)
? o1.Index()

a1 = [ "A", "B", ["A"], "C", "A", "C" ]
o1 = new stzList(a1)
? o1.Index()

a2 = [ "A", "B", "B", "C", "X" ]
a3 = [ "A", "B"]
o1 = new stzListOfLists([ a1,a2,a3 ])

? o1.Index()
