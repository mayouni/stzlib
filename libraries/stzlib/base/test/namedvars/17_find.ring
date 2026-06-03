# Narrative
# --------
# pr()
#
# Extracted from stznamedvarstest.ring, block #17.

load "../../stzBase.ring"

pr()

oFriend = StzNamedObjectQ(:oFriend = new Person("Mahmoud"))

aMyList = [ 10, oFriend, "hello", [1, 2,3 ], oFriend, [1, 2, 3], "HELLO" ]

? @@( @Find(aMyList, 10 ) )          # --> [1]
? @@( @Find(aMyList, "hello") )      # --> [3]
? @@( @Find(aMyList, [1, 2, 3]) )    # --> [4, 6]
? @@( @Find(aMyList, oFriend) )      # --> [2, 5]

? ""

? @@( @FindCS(aMyList, "HELLO", FALSE) )  # --> [3, 7]
? @@( @FindCS(aMyList, "HELLO", TRUE) )   # --> [7]

pf()

class Person
    name = ""
    def init(cName)
        name = cName

# Executed in 0.04 second(s) in Ring 1.23
