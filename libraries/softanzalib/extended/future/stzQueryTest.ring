load "../stzlib.ring"

o1 = new stzQuery([ "a", "b", 1, 2, "C", "d", 3, "E", 4 ])
? o1.FindWhere(:CurrentItem, :IsEqualTo, :NextItem)

{ CurrentItem = Next2ndItem }
