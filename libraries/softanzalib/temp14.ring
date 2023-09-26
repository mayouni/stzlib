load "stzlib.ring"

# Using Section() (or Slice()) to get a part of a list

aList = 1:20

# Verbose form:
? Q(aList).Section(:FromPosition = 4, :To = :LastItem)
#--> 4:20

# Short form:
? Q(1:20).Slice(4, :Last)
#--> 4:20


