load "stzlib.ring"

o1 = new stzSection(1, 5, :InAListOfSize = 10)

? o1.Content()
#--> [ 1, 5 ]

? o1.StartPos()
#--> 1

? o1.EndPos()
#--> 2

? o1.Content(:Start, :End)

