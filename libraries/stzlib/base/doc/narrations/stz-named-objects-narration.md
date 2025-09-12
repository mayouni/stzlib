# Harnessing the Power of Named Objects in Softanza

Softanza's named objects feature tackles a key limitation in Ring: the inability to find objects in lists by their variable names, making them hard to track in complex data structures. Unlike numbers and strings that can be found using `find(oVarName)`, objects in Ring lists remain anonymous. By enabling dynamic naming, Softanza empowers developers to create, find, and manage objects efficiently in real-world applications like data processing, interactive systems, or generative content creation.

## The Problem: Finding Objects in Lists

In Ring, when you have numbers and strings in a list, you can find them easily by their values:

```ring
myList = [10, "hello", 30, "world"]
? find(myList, "hello")  #--> 2
```

But when a list contains objects, this approach doesn't work. Objects lack persistent identifiers that survive in collections, making it difficult to locate specific objects within lists. This becomes particularly challenging when you need to track the same object across different parts of your application.

## The Solution: Named Objects

Softanza solves this by allowing you to assign names to objects, making them findable within lists using their assigned names. There are two main ways to create named objects.

### Creating Named Objects

#### Method 1: Name After Creation

You can create an object first, then assign it a meaningful name later. By default, all Softanza objects start with a placeholder name:

```ring
greeting = new stzString("Hi!")
? greeting.VarName()
#--> @noname
```

Then you can give it a proper name using the `SetVarName()` method:

```ring
greeting.SetVarName(:greeting)
? greeting.VarName()
#--> greeting
```

#### Method 2: Name During Creation

Alternatively, you can name the object at the moment you create it using hashlist syntax. This approach is often more convenient when you know the object's purpose from the start:

```ring
hello = new stzString(:hello = "Hello Ring!")
? hello.VarName()
#--> hello
```

This method creates the object and assigns the name in one step, making your code more concise.

## Finding Named Objects in Lists

Once objects are named, you can find them in lists containing mixed data types. Let's create a test list that combines strings, numbers, and our named Softanza objects:

```ring
o1 = new stzList([ "one", greeting, 12, greeting, Q("two"), hello, 10, Q(10) ])
```

This list contains various elements including our named objects `greeting` and `hello`, plus some unnamed objects created with `Q()`.

### Find Objects by Name

Now you can locate objects by their assigned names. The `FindObject()` method returns all positions where the named object appears:

```ring
? @@( o1.FindObject(:greeting) )
#--> [ 2, 4 ]

? @@( o1.FindObject(:hello) )
#--> [ 6 ]
```

Notice that `greeting` appears twice in our list (at positions 2 and 4), while `hello` appears once at position 6.

### List All Objects with Their Positions

The `ObjectsZ()` method provides a comprehensive view of all objects in the list, showing their names and positions:

```ring
? @@( o1.ObjectsZ() )
#--> [
#    [ "greeting", [ 2, 4 ] ],
#    [ "@noname",  [ 5, 8 ] ],
#    [ "hello",    [ 6 ]    ]
# ]
```

This output shows that we have objects with three different names: "greeting" (at positions 2, 4), "@noname" (at positions 5, 8), and "hello" (at position 6).

### Separate Named from Unnamed Objects

You can also distinguish between objects that have custom names versus those that still use the default "@noname":

```ring
? @@( o1.FindNamedObjects() )
#--> [ 2, 4, 6 ]

? @@( o1.FindUnnamedObjects() )
#--> [ 5, 8 ]
```

The named objects are those we explicitly named (`greeting` and `hello`), while unnamed objects are those created with `Q()` that kept their default names.

### Count and List Object Names

Several methods help you analyze the objects in your list. You can get all object names, including duplicates:

```ring
? o1.ObjectsVarNames()
#--> [ :greeting, :greeting, :hello ]
```

Or get unique names only, removing duplicates:

```ring
? o1.ObjectsVarNamesU()
#--> [ :greeting, :hello ]
```

You can also count objects in different ways:

```ring
? o1.NumberOfNamedObjects()
#--> 3

? o1.NumberOfUniqueNamedObjects()
#--> 2
```

## Practical Examples

### Example 1: User Messages

In a messaging application, you might want to track different types of messages. Here's how named objects make this simple:

```ring
# Create named message objects for easy identification
user_msg = new stzString(:user1_message = "Hello there!")
system_msg = new stzString(:system_response = "Welcome back!")

messages = new stzList(["timestamp", user_msg, "metadata", system_msg])
```

Now you can find specific message types without knowing their exact positions:

```ring
? messages.FindObject(:user1_message)    #--> [2]
? messages.FindObject(:system_response)  #--> [4]
```

### Example 2: Game Items

For a game inventory system, named objects help track different items:

```ring
# Create named game objects representing player equipment
sword = new stzString(:player_sword = "Magic Sword")
shield = new stzString(:player_shield = "Iron Shield")

inventory = new stzList([sword, 100, shield, 50])  # items with quantities
```

Finding specific equipment becomes straightforward:

```ring
? inventory.FindObject(:player_sword)   #--> [1]
? inventory.FindObject(:player_shield)  #--> [3]

# Count unique items in inventory
? inventory.NumberOfUniqueNamedObjects()  #--> 2
```

### Example 3: Configuration Objects

When working with application settings, named objects help organize different configuration types:

```ring
# Create named configuration objects for different app components
db_config = new stzString(:database_config = "host=localhost")
ui_config = new stzString(:ui_config = "theme=dark")

settings = new stzList([db_config, "separator", ui_config])
```

You can then access specific configurations by name:

```ring
? settings.FindObject(:database_config)  #--> [1]
? settings.FindObject(:ui_config)        #--> [3]
```

## Working with Object Collections

Beyond finding individual objects, Softanza provides methods for working with object collections. You can find all objects regardless of their names:

```ring
? @@( o1.FindObjects() )
#--> [ 2, 4, 5, 6, 8 ]
```

Or get details about specific named objects in one call:

```ring
? @@( o1.TheseObjectsZ([ :greeting, :hello ]) )
#--> [
#    [ "greeting", [ 2, 4 ] ],
#    [ "hello", [ 6 ] ]
# ]
```

You can also distinguish between different types of Softanza objects:

```ring
? @@( o1.FindStzObjects() )
#--> [ 2, 4, 5, 6, 8 ]

? @@( o1.FindQObjects() )
#--> [ ]
```

## Debugging Named Objects

When debugging applications with named objects, Softanza provides helpful analysis tools. Let's create a test scenario to demonstrate:

```ring
# Create a test list with various objects for analysis
test_list = new stzList([
    "text",
    new stzString(:named_text = "Named String"),
    42,
    new stzString("Unnamed String"),
    new stzNumber(:counter = 100)
])
```

Now you can analyze the composition of your list:

```ring
# Get basic statistics about the objects
? "=== Object Analysis ==="
? "Total items: " + test_list.NumberOfItems()
? "All objects: " + test_list.NumberOfObjects()
? "Named objects: " + test_list.NumberOfNamedObjects()
? "Unique names: " + test_list.NumberOfUniqueNamedObjects()
```

The `ObjectsZ()` method provides detailed information about each object:

```ring
# Show detailed object mapping
? "=== Object Details ==="
? @@( test_list.ObjectsZ() )
#--> [
#    [ "named_text", [ 2 ] ],
#    [ "@noname", [ 4 ] ],
#    [ "counter", [ 5 ] ]
# ]
```

Finally, you can list all the unique object names in your collection:

```ring
# List all object names for reference
? "Object names: " + @@( test_list.ObjectsVarNamesU() )
#--> [ :named_text, :counter ]
```

## When to Use Named Objects

Named objects are particularly useful in several scenarios. They excel when you need to track specific objects in mixed lists without worrying about their positions. They're also valuable when you want to find objects without knowing their exact location in the list.

The feature becomes especially powerful when you need to distinguish between similar objects that might have the same content but serve different purposes. Named objects also enable building systems where objects need persistent identity that survives across different operations.

Finally, they're ideal for creating collections where objects can be referenced by meaningful names rather than numeric indices, making your code more readable and maintainable.

## Conclusion

Softanza's named objects feature transforms how you work with objects in Ring lists. Instead of relying on positions or complex searching, you can assign meaningful names to objects and find them directly. This simple yet powerful capability makes code more readable and maintainable, especially when working with collections of mixed data types.