load "../stzbase.ring"

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

aNonJsonList = [
	:a = 10,
	:b = 20,
	[
		:d = 30,
		:e = 40
	]
]

? IsJsonList(aNonJsonList)
#--> FALSE

? ListToJson(aNonJsonList)
#--> Incorrect param type! aList must be a well-formatted JSON list.

pf()

/*---

pr()

? ListToJsonXT([
	:a = 10,
	:b = 20,
	:c = [
		:d = 30,
		:e = 40
	]
])
#-->
'
{
	"a": 10,
	"b": 20,
	"c": {
		"d": 30,
		"e": 40
	}
}
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aList = [["name", "John"], ["age", 30]]

? IsHashList(aList)
#--> TRUE

? IsJsonList(aList) # Or simply IsJson()
#--> TRUE

? ListToJson(aList) + NL
#--> {"name":"John","age":30}

? ListToJsonXT(aList) + Nl
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

/*---

pr()

cJsonStr = '
{
	"name": "John",
	"age": 30,
	"hobbies": [
		"sport",
		"cinema"
	]
}
'

? IsJsonString(cJsonStr) # Or simply IsJson()
#--> TRUE

pf()

/*---

pr()

? @@NL( JsonToList('{"name": "John", "age": 30 }') )
#-->
'
[
	[ "name", "John" ],
	[ "age", 30 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*===

pr()

#NOTE: JSON specification does not impose ordering preservation
# of JSON members, and so does Qt, on witch stzJson is based.
# This ensures parsing of large JSON files is done efficiently.

# From JSON string
oJson = new stzJson('{"name": "John", "age": 30 }')

	# Compact form
	? oJson.ToString()
	#--> {"age":30,"name":"John"}
	
	# Indented form
	? oJson.ToStringXT() + NL
	#-->
	'
	{
	    "age": 30,
	    "name": "John"
	}
	'

# From Ring list
oJson = new stzJson([ ["name", "John"], ["age", 30] ])
? oJson.ToStringXT()
#-->
'
{
    "age": 30,
    "name": "John"
}
'

#NOTE how "age" is returned before "name" (read note at the start of sample)

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Example title

pr()

# From JSON string
oJson = new stzJson('{"name": "John", "age": 30 }')

? @@NL( oJson.ToList() )
#-->
'
[
	[ "age", 30 ],
	[ "name", "John" ]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

#========================#
#  STZJSON TEST SAMPLES  #
#========================#



/*--- Basic Initialization from JSON String

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')

? @@NL( oJson.ToList() )
#-->
# Note: Order of key-value pairs may vary due to qt-behavoir (#perf)
# and as stated by the JSON specificztion itself

'
[
	[ "age", 30 ],
	[ "name", "John" ]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Basic Initialization from Ring List

pr()

aList = [ ["name", "Alice"], ["age", 25] ]
oJson = new stzJson(aList)

# compact JSON string

? oJson.ToString()
#--> {"age":25,"name":"Alice"}

# Indented JSON string

? oJson.ToStringXT()
#-->
'
{
    "age": 25,
    "name": "Alice"
}
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Getting Keys

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')

? oJson.Keys()
#--> ["age", "name"]  # Note: Order of keys is not guaranteed

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Accessing Value by Key

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')

? oJson.Value("name")
#--> "John"

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Setting a New Value
*/
pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oJson.SetValue("age", 31)

? oJson.ToString()
#--> {"age":31,"name":"John"}  # Note: Key order may vary

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Removing a Key

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oJson.RemoveKey("age")

? oJson.ToString()
#--> {"name":"John"}

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Taking a Key (Remove and Return Value)

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
vValue = oJson.TakeKey("age")

? vValue
#--> 30

? oJson.ToString()
#--> {"name":"John"}

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Basic Initialization from JSON Array

pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.ToList()
#--> [1, 2, 3]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Checking if it's an Array

pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.IsArray()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Accessing Element by Index

pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.At(2)
#--> 2

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Getting First Element

pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.First()
#--> 1

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Getting Last Element

pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.Last()
#--> 3

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Adding an Element to Array

pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Add(4)

? oJson.ToString()
#--> [1,2,3,4]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Prepending an Element to Array

pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Prepend(0)

? oJson.ToString()
#--> [0,1,2,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Inserting an Element at Position

pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Insert(2, 1.5)

? oJson.ToString()
#--> [1,1.5,2,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Removing an Element by Index

pr()

oJson = new stzJson('[1, 2, 3]')
oJson.RemoveAt(2)

? oJson.ToString()
#--> [1,3]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Taking an Element by Index

pr()

oJson = new stzJson('[1, 2, 3]')
vValue = oJson.TakeAt(2)

? vValue
#--> 2

? oJson.ToString()
#--> [1,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Checking if Element Exists in Array

pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.Contains(2)
#--> TRUE

? oJson.Contains(4)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Replacing an Element in Array

pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Replace(2, 2.5)

? oJson.ToString()
#--> [1,2.5,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Copying a JSON Object

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oCopy = oJson.Copy()

? oCopy.ToString()
#-->
