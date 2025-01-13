# Probabilistic Quantifiers in Softanza

Softanza introduces **probabilistic quantifiers** like `Few()`, `Some()`, `Most()`, and `All()`, enabling intuitive data manipulation by mirroring natural language. These quantifiers map conversational terms to precise proportions, making code both expressive and clear.  

```ring
load "stzlib.ring"

? Some( NumbersIn( -5 : 5 ) )
#--> [ -1, -4, -5, 3 ]

? Most( PositiveNumbersIn( -5 : 5 ) )
#--> [ 1, 2, 4, 5 ]
```

Each probabilistic quantifier corresponds to a default proportion of items:  
- `Few()` → 10%  
- `Some()` → 30%  
- `Most()` → 90%  
- These proportions are fully customizable using commands like `SetFew(0.15)` or `SetMost(0.85)`.

These quantifiers form a continuum:  
**`No()` → `Few()` → `Some()` → `Half()` → `Many()` → `Most()` → `All()`**  

Their true power emerges in probabilistic and random contexts:  

```ring
SetSome(0.4)

? Some( RandomNumbersIn(1:10) )
#--> [ 5, 2, 7, 9 ]

? Few( RandomNumbersInU(1:10) ) # "U" for Unique items
#--> [ 1, 4 ]
```

`All()` and `No()` are straightforward, returning all items in a list or an empty list, respectively:

```ring
? All([ "A", "B", "C" ])
#--> [ "A", "B", "C" ]

? No([ "A", "B", "C" ])
#--> []
```

For semantic convenience, alternative function names like `AllOf()`, `NoOne()`, and `NoOneOf()` are provided. These enable natural expressions such as:

```ring
Them = [ "Andy", "Bill", "Chris" ]

? AllOf(Them)
#--> [ "Andy", "Bill", "Chris" ]

? NoOneOf(Them)
#--> [ ]
```

More interestingly, the **fluent forms** of these functions (using the `Q()` suffix) allow natural, expressive code:

```ring
MyExamNotes = [ 12, 17, 18, 16, 19 ]
Them = MyExamNotes # Semantic alias for clarity
Average = 10

? AllOfQQ(MyExamNotes).ArePositive()
#--> TRUE

? AllOfQQ(Them).AreGreaterThan(Average)
#--> TRUE
```

> **NOTE**: The `Q(aList)` function promotes `aList` to a `stzListObject`, while `QQ(aList)` promotes it to a specific type of Softanza list, like `QQ([1, 2, 3])`, which returns a `stzListOfNumbers` object. This allows the use of specialized functions like `ArePositive()`, `AreGreaterThan()`, etc.


Want to see some logical magic with these quantifiers? Let me show you!

Take the the NothingIn() quantifier, which is the exact alternative of `No()` quantifier we explored earlier. I'll prefix it with `QQ()` becasue I'll feed it with a list of strings containing emails adresses, and then call the Matches() function to check the emails agains the corresponding regular expression pattern.

Now, here’s where it gets exciting—I’ll add also the magical `X()` suffix!

The `X()` suffix introduces a powerful mechanism to express logical statements declaratively and verify them directly. In our case, `NothingInQQX()` checks whether none of the elements in a list satisfy a condition, while `EverythingInQQX()` ensures all elements do. Here's how they work:

```ring
? NothingInQQX([ "aee@net", "@com.com", "--?mail@org" ]).MatchesX(rxp(:eMail))
#--> TRUE  # No element in the list matches the email pattern.

? NothingInQQX([ "aee@net", "@com.com", "--?mail@org", "info@mail.com" ]).MatchesX(rxp(:eMail))
#--> FALSE # At least one element matches the email pattern.

? EverythingInQQX([ "hello@mail.com", "info@mail.org" ]).MatchesX(rxp(:eMail))
#--> TRUE  # All elements match the email pattern.

? EverythingInQQX([ "hello@mail.com", "info@mail.org", "~;@com" ]).MatchesX(rxp(:eMail))
#--> FALSE # Not all elements match the email pattern.
```

This approach bridges intuitive expression and rigorous logic, enabling clear and concise validation of conditions in code.

> **NOTE**: The `rxp(:email)` utility function returns the regular expression pattern for an email, which is `"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"`.

---

Probabilistic quantifiers enhance coding fluency, bridging natural thought and precision. They exemplify Softanza's commitment to making programming intuitive and efficient.


**See them in action in Ring Notepad hereafter:**

![Probabilistic Quantifiers in Softanza](../images/stz-probabilistic-quantifiers.png)