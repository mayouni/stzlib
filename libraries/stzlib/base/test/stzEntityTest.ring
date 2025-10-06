load "../stzbase.ring"


/*---

? @@( TimeStamp() )

/*--- Creating basic entities

pr()

o1 = new stzEntity([
    :name = "john",
    :type = "person"
])

? o1.Name()
#--> john

? o1.Type()
#--> person

? o1.Created()
#--> 2025-09-26 14:30:15 (timestamp)

pf()

/*--- Using the @() wildcard to read and set properties

pr()

o1 = new stzEntity([
	:name = "customer",
	:value = "sonibank"
])

o1 {
	# Checking a property

	? @(:name)
	#--> customer

	? @(:value)
	#--> sonibank

	# Setting a property

	@(:value = "cousbox")
	? @(:value)
	#--> cousbox

	# Setting many properties at once
	@([ :name = "partner", :value = "nigercom", :country = "niger" ])

	? @(:name)
	#--> partner

	? @(:value)
	#--> nigercom

	? @(:country)
	#--> niger
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Entity with custom properties

pr()

o1 = new stzEntity([
    :name = "toyota",
    :type = "car",
    :model = "camry",
    :year = 2023,
    :color = "blue"
])

? o1.Property("model")
#--> camry

? @@(o1.Properties())
#--> ["name", "type", "created", "model", "year", "color"]

? o1.ContainsProperty("year")
#--> 1

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Modifying entity properties

pr()

o1 = new stzEntity([
    :name = "toyota",
    :type = "car",
    :model = "camry",
    :year = 2023,
    :color = "blue"
])

o1 {
	SetProperty("price", 25000) # Or Set@() or @Set() or @(:price = 2500)
	? Property("price") # Or @(:price)
	#--> 25000

	SetName("honda") # Or @(:name = "honda")
	? Name() # Or @(:name)
	#--> honda

	RemoveProperty("color") # or @Remove("color") or Remove@("color")
	? ContainsProperty("color")
	#--> FALSE

	? ContainsValue("camry")
	#--> TRUE

	? ContainsProperty("year") # or ContainsPropOrVal("car") or @Contains() or Contains@()
	#--> TRUE
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Entity type checking

pr()

o1 = new stzEntity([
	:name = "john",
	:type = "person",
	:age = 35,
	:job = "programmer"
])

? o1.IsOfType("person")
#--> 1

? o1.HasName("john")
#--> 1

? o1.Size()
#--> 5

o1.Show()
#-->
# Entity: john (Type: person)
#  age: 35
#  job: programmer
#  created: 06/10/2025 21:34:40

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Creating list of entities

pr()

aEntities = [
    [ :name = "alice", :type = "person", :age = 30 ],
    [ :name = "bob", :type = "person", :age = 25 ],
    [ :name = "ferrari", :type = "car", :brand = "ferrari" ],
    [ :name = "laptop", :type = "device", :brand = "dell" ]
]

oList = new stzListOfEntities(aEntities)

? oList.NumberOfEntities()
#--> 4

? @@(oList.Names())
#--> ["alice", "bob", "ferrari", "laptop"]

? @@(oList.Types())
#--> ["person", "person", "car", "device"]

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Finding entities
*/
pr()

o1 = new stzEntities([

])

? oList.FindEntityByName("alice")
#--> 1

? oList.ContainsType("car")
#--> 1

? oList.CountByType("person")
#--> 2

? oList.FindEntitiesByType("person")
#--> [1, 2]

pf()

/*--- Getting specific entities

? oList.FirstEntity()[:name]
#--> alice

? oList.LastEntity()[:name]
#--> laptop

aPersons = oList.EntitiesOfType("person")
? len(aPersons)
#--> 2

/*--- Adding entities

oList.AddEntity([ :name = "truck", :type = "vehicle", :wheels = 6 ])

? oList.NumberOfEntities()
#--> 5

? oList.HasEntity("truck")
#--> 1

/*--- Removing entities

oList.RemoveEntity("ferrari")
? oList.NumberOfEntities()
#--> 4

? oList.ContainsName("ferrari")
#--> 0

/*--- Filtering and sorting

oPersonsList = oList.FilterByType("person")
? oPersonsList.NumberOfEntities()
#--> 2

oList.SortByName()
? oList.Names()
#--> ["alice", "bob", "laptop", "truck"]

oList.SortByType()
? oList.Types()
#--> ["device", "person", "person", "vehicle"]

/*--- List operations

? oList.IsEmpty()
#--> 0

? oList.UniqueTypes()
#--> ["device", "person", "vehicle"]

oList.Show()
#-->
# List of Entities (4 entities):
# ================================================
# 1. laptop (device)
# 2. alice (person)
# 3. bob (person)
# 4. truck (vehicle)

/*--- Copying and clearing

oListCopy = oList.Copy()
? oListCopy.NumberOfEntities()
#--> 4

oList.Clear()
? oList.IsEmpty()
#--> 1

? oListCopy.IsEmpty()
#--> 0

/*--- Error handling examples

// This will raise an error
try
    oWrong = new stzEntity([ :type = "person" ])  # Missing name
catch
    ? "Error: Entity must have a name"
end
#--> Error: Entity must have a name

// This will raise an error
try
    oEntity1.RemoveProperty("name")  # Can't remove core property
catch
    ? "Error: Cannot remove core property"
end
#--> Error: Cannot remove core property

/*--- Complex entity with metadata

oComplexEntity = new stzEntity([
    :name = "server01",
    :type = "computer",
    :ip = "192.168.1.100",
    :os = "linux",
    :memory = "32GB",
    :status = "active",
    :owner = "IT Department"
])

? oComplexEntity.Size()
#--> 8

? oComplexEntity.ContainsValue("linux")
#--> 1

oComplexEntity.Show()
#-->
# Entity: server01 (Type: computer)
#   created: 2025-09-26 14:30:15
#   ip: 192.168.1.100
#   os: linux
#   memory: 32GB
#   status: active
#   owner: IT Department
