load "../stzbase.ring"


/*---

? @@( TimeStamp() )

/*--- Creating basic entities
*/
pr()

oEntity = new stzEntity([
    :name = "john",
    :type = "person"
])

? oEntity.Name()
#--> john

? oEntity.Type()
#--> person

? oEntity.Created()
#--> 2025-09-26 14:30:15 (timestamp)

pf()

/*--- Entity with custom properties

pr()

oEntity2 = new stzEntity([
    :name = "toyota",
    :type = "car",
    :model = "camry",
    :year = 2023,
    :color = "blue"
])

? oEntity2.Property("model")
#--> camry

? @@(oEntity2.Properties())
#--> ["name", "type", "created", "model", "year", "color"]

? oEntity2.ContainsProperty("year")
#--> 1

pf()

/*--- Modifying entity properties
*/
pr()

oEntity = new stzEntity([
    :name = "toyota",
    :type = "car",
    :model = "camry",
    :year = 2023,
    :color = "blue"
])

oEntity.SetProperty("price", 25000)
? oEntity.Property("price")
#--> 25000

oEntity.SetName("honda")
? oEntity.Name()
#--> honda

oEntity.RemoveProperty("color")
? oEntity.ContainsProperty("color")
#--> 0

pf()

/*--- Entity type checking

? oEntity1.IsOfType("person")
#--> 1

? oEntity1.HasName("john")
#--> 1

? oEntity2.Size()
#--> 5

oEntity2.Show()
#-->
# Entity: honda (Type: car)
#   created: 2025-09-26 14:30:15
#   model: camry
#   year: 2023
#   price: 25000

/*--- Creating list of entities

aEntities = [
    [ :name = "alice", :type = "person", :age = 30 ],
    [ :name = "bob", :type = "person", :age = 25 ],
    [ :name = "ferrari", :type = "car", :brand = "ferrari" ],
    [ :name = "laptop", :type = "device", :brand = "dell" ]
]

oList = new stzListOfEntities(aEntities)

? oList.NumberOfEntities()
#--> 4

? oList.Names()
#--> ["alice", "bob", "ferrari", "laptop"]

? oList.Types()
#--> ["person", "person", "car", "device"]

/*--- Finding entities

? oList.FindEntityByName("alice")
#--> 1

? oList.ContainsType("car")
#--> 1

? oList.CountByType("person")
#--> 2

? oList.FindEntitiesByType("person")
#--> [1, 2]

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
