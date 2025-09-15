# Named Variables in Softanza: the What, Why and How!

## Introduction

Softanza's NamedVars feature enables construction of variable names at runtime. This powerful capability is useful for:

- Creating variables with systematic naming patterns (name1, name2, ..., name100)
- Variables whose names depend on runtime data (user IDs, file hashes)
- Advanced scenarios in interactive apps, game development, ML/AI, and rule engines
- Near Natural Language programming features

## Core Functions

- `Vr()` - Variable Reference (left side of assignment)
- `Vl()` - Variable Value (right side of assignment)
- `v()` - Get variable value
- `VrVl()` - Variable Reference and Value combined
- `vxt()` - Variable name and value extended info

## Basic Named Variable Creation

The most common use case is creating multiple variables that follow a naming pattern. Instead of writing dozens of variable declarations, you can use a loop to construct both the variable names and their values programmatically.

### Creating Multiple Variables in a Loop

```ring
# Create 10 variables (name1 to name10) with values (10 to 100)
for i = 1 to 10 { Vr( 'name' + i ) '=' Vl( 10 * i ) } 

# Access the variables
? v( :name3 )
#--> 30

? v( :name7 )
#--> 70
```

Once named variables are created, you have several ways to modify their values. Softanza provides both the original Vr/Vl syntax and a more convenient combined syntax.

### Modifying Named Variables

```ring
# Change value using Vr/Vl syntax
Vr( :name3 ) '=' Vl( 44 )
? v(:name3)
#--> 44

# Or using VrVl combined syntax
VrVl( :name3 = 30 )
? v(:name3)
#--> 30
```

Beyond simple value retrieval, you often need both the variable name and its value for debugging, logging, or meta-programming purposes.

### Getting Variable Name and Value

```ring
# Get both name and value
? @@( vxt( :name3 ) )
#--> [ "name3", 30 ]

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

## Multiple Variable Assignment

Working with sets of related variables is common in programming. Softanza allows you to assign values to multiple variables simultaneously, making code more concise and expressive.

### Assigning Arrays to Multiple Variables

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

When you need to assign a single value to one variable, the array syntax still works. This maintains consistency with the multiple assignment pattern.

### Single Variable Assignment

```ring
# Assign specific values to multiple variables
Vr([ :x, :y, :z ]) '=' Vl([ -1, 0, 1 ])
? v([ :x, :y, :z ])
#--> [ -1, 0, 1 ]
```

You can also assign a list as the value of a single variable using the same syntax pattern.

```ring
# Assign an array as the value to the :names variable
Vr([ :names ]) '=' Vl([ [ "Hussein", "Haneen", "Teebah" ] ])
? @@( v(:names) )
#--> [ "Hussein", "Haneen", "Teebah" ]
```

Multiple assignment also works with mixed data types - strings, numbers, arrays, etc.

```ring
# Assign different data types to multiple variables
Vr([ :name, :grades, :age ]) '=' Vl([ "Mansour", [10, 12, 15], 47 ])
? @@( v(:grades) )
#--> [ 10, 12, 15 ]
```

### Nested Array Assignment

```ring
# Assign an array as a single value
Vr([ :names ]) '=' Vl([ [ "Hussein", "Haneen", "Teebah" ] ])
? @@( v(:names) )
#--> [ "Hussein", "Haneen", "Teebah" ]
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

## Range-Based Variable Creation

When you need to create many variables with systematic names, range-based creation provides an elegant solution. This is especially useful for creating variables that correspond to alphabetic or numeric sequences.

### Creating Variables from Character Ranges

```ring
# Create variables a to z with values 1 to 26
Vr( "a" : "z" ) '=' Vl( 1 : NumberOfLatinLetters() )
? v(:t)
#--> 20
```

## Error Handling and Edge Cases

Understanding how NamedVars handles unusual situations helps you write robust code that gracefully handles various scenarios.

### Duplicate Variable Names

```ring
# Last assignment wins with duplicate names
Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen", "Teeba" ])
? v(:name2)
#--> Teeba
```

When you don't provide enough values for all variables, Softanza handles this gracefully by setting missing variables to empty strings.

### Insufficient Values

```ring
# Missing values default to empty string
Vr([ :name1, :name2, :name3 ]) '=' Vl([ "Hussein", "Haneen" ])
? @@( TempVarsXT() )
#--> [ :say = null, :name1 = "Hussein", :name2 = "Haneen", :name3 = "" ]

? @@( v(:name3) )
#--> ""
```

### Multiple Data Assignment

```ring
# Assign different data types to multiple variables
Vr([ :name, :grades, :age ]) '=' Vl([ "Mansour", [10, 12, 15], 47 ])
? @@( v(:grades) )
#--> [ 10, 12, 15 ]
```

## Named Objects: A Special Kind of Named Variable

Named objects extend the NamedVars concept to Softanza objects, making them findable in lists through a unified interface.

> **Note:** Ring offers multiple finding approaches at different abstraction levels - high-level for values, low-level `ref()` for objects, and attribute-based searching. Named objects provide consistency by keeping object finding at the language level rather than mixing abstraction levels. For a detailed analysis of this design approach, see [The Unified @Find() Function in Softanza](LINK_TO_BE_PROVIDED).

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