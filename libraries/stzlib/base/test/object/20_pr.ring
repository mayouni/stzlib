# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #20.

load "../../stzBase.ring"


? Q("2").IsA([ :Number, :String, :List ])
#--> FALSE

? Q([10, 20]).IsA([ :List, :Pair, :ListOfNumbers, :PairOfNumbers ])
#--> TRUE

? Q("str").IsAList()
#--> FALSE

? Q("str").IsANumber()
#--> FALSE

? Q("str").IsAString()
#--> TRUE

? Q("5").IsNumberInString()
#--> TRUE

? Q("str").IsA(:String)
#--> TRUE

? Q("str").IsA(:StzString)
#--> TRUE

? Q("str").IsAn(:Object)
#--> TRUE

? Q("2").IsAString()
#--> TRUE

? Q("2").IsA(:String)
#--> TRUE

? Q("2").IsAXT([ :NumberInString ])
#--> TRUE

? Q("2").IsA(:NumberInString)
#--> TRUE

? Q("2").Is(:NumberInString)
#--> TRUE

? Q("2").Is(:NumberInString)
#--> TRUE

#--> TRUE

? Q("2").IsEitherA(:Number, :Or = :String)
#--> TRUE

? Q("2").IsOneOfThese([ 3, "2", 5 ])
#--> TRUE

? Q([ 10, 20, 30 ]).IsA(:ListOfNumbers)
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.21
