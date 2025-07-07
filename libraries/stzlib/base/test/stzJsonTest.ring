load "../stzbase.ring"
load "jsonlib.ring"
/*===

pr()

oByteArray = new QByteArray()
oByteArray.append("XYZ")

? QByteArrayToString(oByteArray)
#--> XYZ

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*---

pr()

? IsQByteArray( StringToQByteArray("XYZ") )
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*---

pr()

? List2Json([ :a = 10, :b = 20, [ :c = 30, :d = 40 ] ])
#-->
'
{
	"a": 10,
	"b": 20,
	{
		"c": 30,
		"d": 40
	}
}
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? IsHashList([["name", "John"], ["age", 30]])
#--> TRUE

? ListToJson([["name", "John"], ["age", 30]]) + NL
#--> {"name":"John","age":30}

? ListToJsonXT([["name", "John"], ["age", 30]]) + Nl
#-->
'
{
	"name": "John",
	"age": 30
}
'

? ListToJsonXT([["name", "John"], ["age", 30], ["hobbies", ["sport", "cinema"]]])
#--> Returns
'
{
	"name": "John",
	"age": 30,
	"hobbies": [
		"sport",
		"cinema"
	]
}
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*===
*/
pr()

# From JSON string
oJson = new stzJson('{"name": "John", "age": 30 }')
? oJson.ToString()
#-->
'
{
    "age": 30,
    "name": "John"
}
'

# From Ring list
oJson = new stzJson([["name", "John"], ["age", 30]])
? oJson.ToStringXT()
#-->
'
{
    "age": 30,
    "name": "John"
}
'

pf()
/*
# Chaining operations
oJson.SetValue("city", "Paris").SetValue("country", "France")
? @@NL( oJson.Content() ) + NL

# Array operations
oArray = new stzJson("[]")
oArray.Add("item1").Add("item2").Insert(2, "middle")
? @@NL( oJson.Content() ) + NL

# Path navigation
value = oJson.GetPath("user.profile.email")
