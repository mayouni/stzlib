# Narrative
# --------
#
# Extracted from stzGlobalTest.ring, block #50.

load "../../../stzBase.ring"

pr()

# The InfereType() function is useful for internal features
# of SoftanzaLib, in order to enable the goal of expressive code.

# In particular, it is used in the stzList.IsListOf(pcType) method.

# From a particular string, it tries to detect the most relevant
# Ring or Softanza type.

# So, Softanza can do its best to infere the type included
# in a string, whatever form the string takes: lowercase or
# uppercase, and singular or plural!

? Q('number').InfereType()		#--> :Number
? Q('String').InfereType()		#--> :String

? Q('NuMBer').InfereType()		#--> :Number
? Q('STRING').InfereType()		#--> :String

? Q('numbers').InfereType()		#--> :Number
? Q('STRINGS').InfereType()		#--> :String

? Q(:StzNumber).InfereType()		#--> :StzNumber
? Q(:StzNumbers).InfereType()		#--> :StzNumber

? Q(:ListOfNumbers).InfereType()	#--> :List
? Q(:ListsOfNumbers).InfereType()	#--> :List

? Q(:PairOfNumbers).InfereType()	#--> :List
? Q(:PairsOfNumbers).InfereType()	#--> :List

? Q(:StzListOfNumbers).InfereType()	#--> :StzListOfNumbers
? Q(:StzListsOfNumbers).InfereType()	#--> :StzListOfNumbers

? Q(:ListOfStzStrings).InfereType()	#--> :List
? Q(:ListsOfStzStrings).InfereType()	#--> :List

? Q(:Pair).InfereType()			#--> :List

pf()
# Executed in 0.03 second(s).
