# Narrative
# --------
# #narration NAMING UNNAMED OBJECTS AND MAKING THEM FINDABLE
#
# Extracted from stznamedvarstest.ring, block #13.
#ERR exit 3221225794

load "../../stzBase.ring"


pr()

# By default, a softanza object is created with no name
# (actually, with a name called :@noname)

oGreeting = new stzString("Hi!")
? oGreeting.VarName()
#--> @noname

# You can name the object afterward, like this:
oGreeting.SetVarName(:oGreeting) # Or RenameIt()
# and than you can read the name:
? oGreeting.VarName()
#--> ogreeting

# Or you can create the named object in the same time as the object
# it self, by providing a hashlist like this:

oHello = new stzString(:oHello = "Hello Ring!")
# and than you can read the name:
? oHello.VarName() + NL
#--> ohello

# In both cases, we have now objects that we can refer to by their
# names we gave them in our code. And so, we can find them inside a list!

o1 = new stzList([ "one", oGreeting, 12, oGreeting, Q("two"), oHello, 10 , Q(10) ])

? @@( o1.FindObjects() )
#--> [ 2, 4, 5, 6, 8 ]

? @@( o1.ObjectsZ() ) + NL # Or ObjectsAndTheirPositions()
#--> [
#	[ "ogreeting", [ 2, 4 ] ],
#	[ "@noname",  [ 5, 8 ] ],
#	[ "ohello",    [ 6 ]    ]
# ]

? @@( o1.FindObject(:oGreeting) )
#--> [ 2, 4 ]

? @@( o1.FindObject(:oHello) )
#--> [ 6 ]

? @@( o1.FindNamedObjects() )
#--> [ 2, 4, 6 ]

# ? @@( o1.NamedObjectsZ() ) #TODO

? @@( o1.FindUnnamedObjects() )
#--> [ 5, 8 ]

# //? @@( o1.UnnamedObjectsZ() ) #TODO

# ? @@( o1.FindTheseObjects([ :greeting, :hello ]) ) #TODO
#--> [ 2, 4, 6 ]

# ? @@( o1.FindTheseObjects([ :@noname, :hello ]) ) + NL #TODO
#--> [ 5, 6, 8 ]

? @@( o1.TheseObjectsZ([ :@noname, :oHello ]) ) + NL
#--> [
#	[ "@noname", [ 5, 8 ] ],
#	[ "hello", [ 6 ] ]
# ]

#--

? @@( o1.FindStzObjects() ) + NL
# [ 2, 4, 5, 6, 8 ]

#--

? @@( o1.FindQObjects() )
#--> [ ]

#--

? @@( o1.FindNonStzObjects() )
#--> [ ]

#--

? o1.ObjectsVarNames()
#--> [ "ogreeting", "ogreeting", "ohello" ]

? o1.NumberOfNamedObjects()
#--> 3

? o1.ObjectsVarNamesU()
#--> [ "ogreeting", "ohello" ]

? o1.NumberOfUniqueNamedObjects()
#--> 2

#--

? @@NL( o1.NamedObjects() ) + NL
#--> [ "ogreeting", "ogreeting", "ohello" ]

? @@NL( o1.UnamedObjects() )
#--> [ "ogreeting", "ohello" ]

pf()
# Executed in 0.16 second(s) in Ring 1.23
