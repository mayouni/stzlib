# Named Variables in Softanza: the What, Why and How!

## Introduction

Softanza's NamedVars feature enables construction of variable names at runtime. This powerful capability is useful for:

* Creating variables with systematic naming patterns (name1, name2, ..., name100)
* Variables whose names depend on runtime data (user IDs, file hashes)
* Advanced scenarios in interactive apps, game development, ML/AI, and rule engines
* Near Natural Language programming features

## Core Functions

* `Vr()` - Variable Reference (left side of assignment)
* `Vl()` - Variable Value (right side of assignment)
* `v()` - Get variable value
* `VrVl()` - Variable Reference and Value combined
* `vxt()` - Variable name and value extended info

## Basic Named Variable Creation

The simplest use case is creating a single named variable at runtime and accessing its value.

### Creating a Single Named Variable

```ring
# Create one variable with a constructed name
Vr( 'user_' + 123 ) '=' Vl( "Hussein" )

# Access the variable
? v( :user_123 )
#--> Hussein
```

## Assigning Values to Named Variables

Once named variables are created, you can modify their values using either the original Vr/Vl syntax or the more convenient combined syntax.

```ring
# Change value using Vr/Vl syntax
Vr( :user_123 ) '=' Vl( "Mansour" )
? v(:user_123)
#--> Mansour

# Or using VrVl combined syntax
VrVl( :user_123 = "Ahmad" )
? v(:user_123)
#--> Ahmad
```

### Getting Variable Name and Value

Beyond simple value retrieval, you often need both the variable name and its value for debugging, logging, or meta-programming purposes.

```ring
# Get both name and value
? @@( vxt( :user_123 ) )
#--> [ "user_123", "Ahmad" ]
```

## Multiple Variable Assignment

Working with sets of related variables is common in programming. Softanza allows you to assign values to multiple variables simultaneously.

### Assigning to Multiple Variables at Once

```ring
# Assign different values to x, y, z in a loop
for i = 1 to 3
    Vr([ :x, :y, :z ]) '=' Vl([ i, 2*i, 3*i ])
next

# Check final values
? @@( v([ :x, :y, :z ]) )
#--> [ 3, 6, 9 ]

# Get names and values together
? @@( VarVal([ :x, :y, :z ]) ) # Same as VrVl()
#--> [ [ "x", 3 ], [ "y", 6 ], [ "z", 9 ] ]
```

### Creating Multiple Variables in a Loop

```ring
# Create 10 variables (name1 to name10) with values (10 to 100)
for i = 1 to 10 { Vr( 'name' + i ) '=' Vl( 10 * i ) } 

# Access the variables
? v( :name3 )
#--> 30

? v( :name7 )
#--> 70

# Display all variables and values
for i = 1 to 10 { ? @@(vxt( 'name' + i )) }
#--> [ "name1", 10 ]
#    [ "name2", 20 ]
#    [ "name3", 30 ]
#    [ "name4", 40 ]
#    [ "name5", 50 ]
#    [ "name6", 60 ]
#    [ "name7", 70 ]
#    [ "name8", 80 ]
#    [ "name9", 90 ]
#    [ "name10", 100 ]
```

### Range-Based Multiple Assignment

When you need to create many variables with systematic names, you can use ranges. In Ring, "a":"z" creates a list of letters from "a" to "z", and 1:26 creates a list of numbers from 1 to 26.

```ring
# Create variables a to z with values 1 to 26
Vr( "a" : "z" ) '=' Vl( 1 : NumberOfLatinLetters() )
? v(:t)
#--> 20
```

## Variable State Tracking

Softanza keeps track of variable assignments and changes, allowing you to inspect the history of modifications. This is valuable for debugging and understanding variable state changes.

### Temporary Values and History

```ring
# Check initial state
? @@( tempval() )
#--> ""
? @@( oldval() )
#--> ""

# Set a variable
vr([ :name ]) '=' vl([ "mansour" ])
? v(:name)
#--> mansour

# Check current values
? @@( tempval() )
#--> mansour
? @@( oldval() )
#--> mansour

# Change the variable
setV(:name = "cherihen")
? v(:name)
#--> cherihen

# Check value history
? @@( tempval() )
#--> cherihen
? @@( oldval() )
#--> mansour

? @@( tempvarname() ) # same as tempvar()
#--> name
```

## Error Handling and Edge Cases

Understanding how NamedVars handles unusual situations helps you write robust code that gracefully handles various scenarios.

### Use of Same Variable Name Many Times

When you assign to variables with duplicate names, the last assignment takes precedence.

```ring
# Last assignment wins with duplicate names
Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen", "Teeba" ])
? v(:name2)
#--> Teeba
```

### Insufficient Values

When you don't provide enough values for all variables, Softanza sets missing variables to empty strings.

```ring
# Missing values default to empty string
Vr([ :name1, :name2, :name3 ]) '=' Vl([ "Hussein", "Haneen" ])
? @@( TempVarsXT() )
#--> [ :say = null, :name1 = "Hussein", :name2 = "Haneen", :name3 = "" ]

? @@( v(:name3) )
#--> ""
```

## Named Objects: A Special Kind of Named Variable

Named objects extend the NamedVars concept to Softanza objects, making them findable in lists through a unified interface.

> **Note:** Ring offers multiple finding approaches at different abstraction levels - high-level for values, low-level `ref()` for objects, and attribute-based searching. Named objects provide consistency by keeping object finding at the language level rather than mixing abstraction levels. For a detailed analysis of this design approach, see [The Unified @Find() Function in Softanza](https://claude.ai/chat/LINK_TO_BE_PROVIDED).

### Creating Named Objects

```ring
# Default object (unnamed)
oGreeting = new stzString("Hi!")
? oGreeting.VarName()
#--> @noname

# Name it afterward
oGreeting.SetVarName(:oGreeting)
? oGreeting.VarName()
#--> ogreeting

# Or create with name directly
oHello = new stzString(:oHello = "Hello Ring!")
? oHello.VarName()
#--> ohello
```

Once you have named objects, you can search for them in lists by name, which provides a more elegant way to work with object collections than Ring's built-in approaches.

### Finding Named Objects in Lists

```ring
o1 = new stzList([ "one", oGreeting, 12, oGreeting, Q("two"), oHello, 10 , Q(10) ])

# Find all objects
? @@( o1.FindObjects() )
#--> [ 2, 4, 5, 6, 8 ]

# Find objects with their names and positions
? @@( o1.ObjectsZ() )
#--> [
#     [ "ogreeting", [ 2, 4 ] ],
#     [ "@noname",  [ 5, 8 ] ],
#     [ "ohello",    [ 6 ]    ]
# ]

# Find specific named object
? @@( o1.FindObject(:oGreeting) )
#--> [ 2, 4 ]

# Find only named objects
? @@( o1.FindNamedObjects() )
#--> [ 2, 4, 6 ]

# Find only unnamed objects
? @@( o1.FindUnnamedObjects() )
#--> [ 5, 8 ]
```

Object naming can be changed after creation, providing flexibility in how you organize and reference your objects.

### Object Name Management

```ring
# Check if object is named
o1 = new stzString(:nation = "Niger")
? IsNamedObject(o1)
#--> TRUE

? ObjectName(o1)
#--> nation

# Rename objects
o1.RenameIt(:country) # Or SetVarName()
? o1.VarName()
#--> country
```

Working with object collections becomes more powerful when you can analyze the distribution and characteristics of named vs unnamed objects.

### Advanced List Operations with Named Objects

```ring
# Get object variable names
? o1.ObjectsVarNames()
#--> [ "ogreeting", "ogreeting", "ohello" ]

? o1.NumberOfNamedObjects()
#--> 3

# Get unique names only
? o1.ObjectsVarNamesU()
#--> [ "ogreeting", "ohello" ]

? o1.NumberOfUniqueNamedObjects()
#--> 2
```

## Use Cases

NamedVars makes Softanza particularly suitable for applications requiring high flexibility in variable management and runtime adaptability. They can be particularly powerful for:

1. **Data Processing**: Creating variables based on dataset columns or user inputs
2. **Game Development**: Dynamic object creation based on game state
3. **Configuration Management**: Runtime variable creation from config files
4. **Template Systems**: Dynamic content generation
5. **AI/ML Applications**: Variable feature engineering
6. **Code Generation**: Meta-programming scenarios
