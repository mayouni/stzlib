# Probabilistic Quantifiers in Softanza

Softanza introduces **probabilistic quantifiers** like `Few()`, `Some()`, `Most()`, and `All()`, enabling intuitive data manipulation by mirroring natural language. These quantifiers map conversational terms to precise proportions, making code both expressive and clear.  

```ring
? Some( NumbersIn( -5 : 5 ) )
#--> [ -1, -4, -5, 3 ]
? Most( PositiveNumbersIn( -5 : 5 ) )
#--> [ 1, 2, 4, 5 ]
```

Each probabilistic quantifier corresponds to a default proportion of items:  
- `Few()` → 10%  
- `Some()` → 30%  
- `Most()` → 90%  
- Fully customizable with commands like `SetFew(0.15)` or `SetMost(0.85)`.

These quantifiers form a continuum:  
**`No()` → `Few()` → `Some()` → `Half()` → `Many()` → `Most()` → `All()`**  

Their true power emerges in probabilistic and random contexts:  

```ring
SetSome(0.4)
? Some( RandomNumbersIn(1:10) )
#--> [ 5, 2, 7, 9 ]
? Few( RandomNumbersInU(1:10) ) # Unique items
#--> [ 1, 4 ]
```

Probabilistic quantifiers enhance coding fluency, bridging natural thought and precision. They exemplify Softanza's commitment to making programming intuitive and efficient.

See them in action in Ring Notepad hereafter:
![Probabilistic Quantifiers in Softanza](../images/stz-probabilistic-quantifiers.png)