load "../stzlib.ring"


o1 = new stzSet([ "a", "c", "c", "d", "e", "f" ])
? o1.Set()

o1.AddElement("k")
? o1.Set()

/*-----------------

o1 = new stzSet([ "a", "c", 2, 2, "c", "d", "e", "f", [ "item1", "item2" ], [ "item1", "item2" ] ])
? o1.Set()
