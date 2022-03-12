load "guilib.ring"

? type(1:1)
/*
o1 = new qstring2()
o1.append("this is my text")
o1.replace_2("This", "here", TRUE)
? o1.left(o1.count())
/*
load "stzlib.ring"


o1 = new stzString("Rixo Rixo Rixo")
? o1.ReplaceAllQ("xo", "ng").Content()


o1 = new stzString("Python")
o2 = new stzString("Ring")
/*
oList = new stzList([ o1, o2 ])
? oList.ApplyCode("oEachObject.Content()", :ToObjects)

? CallMethod( "Content()", :On = [ :o1, :o2 ] )


/*
o1.SwapWith(o2)
? o1.Content()
? o2.Content()
/*
o1 = new stzString("Rixo Rixo Rixo")
//? o1.ReplaceQ("xo", "ng").Content()
? o1.ReplaceQ("xo", "ng").Content()
//? o1.Content()
/*
o1 = new stzNumber("249")
? o1.DivideByManyXT([ "4", "5", "3"], :ReturnIntermediateResults = TRUE)
/*
o1 = new stzListOfStrings([
	"11", "101", "110", "112", "113", 
	"114", "115", "116", "117", "118",
	"119", "121", "131", "141", "151", 
	"161", "171", "181", "191", "211",
	"311", "411", "511", "611", "711", 
	"811", "911" 
]

? o1.ItemsWhere('NumberOfOccurence("1")', :IsEqualTo, 2 )

// Or, if you want:
? o1.ItemsWhere('/*
StringContainsNTimes
*/(2, "1")')

