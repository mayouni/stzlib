# The Unified @Find() Function: Addressing Ring's Fragmented Finding Experience

Ring provides multiple approaches for finding different data types, each effective for its specific use case. However, this fragmented experience requires programmers to navigate different abstraction levels and conceptual domains, creating cognitive overhead and inconsistency. Softanza addresses these challenges with a unified `@Find()` function that maintains consistency across all data types at the same abstraction level.

## Ring's Multi-Level Finding Landscape

Ring offers several finding approaches that operate at different conceptual levels, each with its own syntax and mental model:

* **High-Level Value Finding**: For primitive types (numbers and strings)

```ring
myList = [10, "hello", 42, "world"]
? find(myList, "hello")    #--> 2
? find(myList, 42)         #--> 3
```

* **Low-Level Reference Management**: For complex types (lists and objects)

```ring
oMyPoint = new Point
aInnerList = [1, 2, 3]
aList = [ 22, ref(oMyPoint), "B", ref(aInnerList) ]
? find(aList, 22) 			#--> 1
? find(aList, "B")			#--> 3
? find(aList, aInnerList) 	#--> 0  # Fails without ref()
? find(aList, oMyPoint)		#--> 0  # Fails without ref()
pf()
class Point { x=10 y=10 z=10 }
```

* **Application Domain Attribute Finding**: For object properties

```ring
myList1 = [
	new Company {position=3 name="Mahmoud" symbol="MHD"},
	new Company {position=2 name="Bert" symbol="BRT"},
	new Company {position=1 name="Ring" symbol="RNG"}
]
see find(mylist1,"Bert", 1, "name") #--> 2
#NOTE: The 1 param represents nColumn in find(List,ItemValue,nColumn,cAttribute)

class company position name symbol
```

There are two main concerns here:

* **Syntactic complexity**: The attribute syntax `find(list, value, nColumn, attribute)` introduces tabular data concepts (`nColumn`) that aren't immediately clear when working with object collections
* **Conceptual inconsistency**: Using application-domain logic (object attributes) to solve a language-level problem (finding objects) violates separation of concerns

## Softanza's Unified Solution

Softanza eliminates these challenges by maintaining object finding at the language level through named objects, providing a consistent interface across all data types:

```ring
oFriend = StzNamedObjectQ(:oFriend = new Person("Mahmoud"))
aMyList = [ 10, oFriend, "hello", [1, 2, 3], oFriend, [1, 2, 3], "HELLO" ]

? @@( @Find(aMyList, 10 ) )          # --> [1]
? @@( @Find(aMyList, "hello") )      # --> [3]
? @@( @Find(aMyList, [1, 2, 3]) )    # --> [4, 6]
? @@( @Find(aMyList, oFriend) )      # --> [2, 5]
? ""
? @@( @FindCS(aMyList, "HELLO", FALSE) )  # --> [3, 7]  # Case-insensitive
? @@( @FindCS(aMyList, "HELLO", TRUE) )   # --> [7]     # Case-sensitive
pf()

class Person
    name = ""
    def init(cName)
        name = cName
```

### Trade-offs and Design Considerations

In an ideal world, named objects wouldn't be necessary if Ring could apply unified logic to `find()` for all types at the same abstraction level. While Softanza's solution resolves the inconsistency, it requires additional setup work—programmers must define named objects before use, as shown in the first line above.

**Best Practice**: Use the same identifier for both the variable name and the named object (`:oFriend` matching the variable `oFriend`). This creates a clear mapping between your code's variable names and their findable representations, maintaining conceptual clarity.

## Conclusion

Ring's multiple finding approaches, while functional for their specific domains, create a fragmented developer experience that forces programmers to context-switch between different abstraction levels and conceptual models. The attribute-based approach is particularly problematic as it conflates application domain concerns with language-level mechanics while introducing non-intuitive syntax patterns.

Softanza's unified `@Find()` function with named objects maintains clear separation of concerns while providing a consistent, high-level interface that better aligns with Ring's core philosophy of simplicity and developer ergonomics. This approach reduces cognitive load and creates a more predictable, maintainable codebase.