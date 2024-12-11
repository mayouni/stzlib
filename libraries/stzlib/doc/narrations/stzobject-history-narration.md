# The Narrative of Transformations: Tracking Object History in Softanza
![Tracking Object History in Softanza, by Microsoft Image Create AI](../images/stzobject-history.jpg)


## Unveiling the Story Behind Data Mutations

In programming, data transformations often happen in the blink of an eye, leaving no trace of their journey. Softanza challenges this paradigm with a groundbreaking feature that captures the entire lifecycle of object modifications.

---

## The Initial Approach: Transformation Without History

First, let's load the library:

```ring
load "stzlib.ring"
```

Consider this basic string transformation chain in Softanza:

```ring
? Q("1 AA 2 B 3 CCC 4 DD 5 Z").
    RemoveWXTQ('{ Q(@Char).IsNumberInString() }').
    RemoveSpacesQ().
    RemoveDuplicatedCharsQ().
    Content()

#--> ABCDZ
```

Here, we process the string, removing numbers, spaces, and duplicate characters. The result is clear, but the path is forgotten.

>**NOTE**: The `Q(val)` small function elevates the value `val`, whatever type it has, to the corresponding Softanza object. In our case, it creates a `stzString` object from the string `"1 AA 2 B 3 CCC 4 DD 5 Z"`.

## The Challenge: Preserving the Transformation Trail

What if we could capture each step of this transformation? Imagine a programming feature that doesn't just give you the final result, but tells you the entire story of how that result was achieved.


## The Solution: Introducing `QH()` small function

```ring
? @@NL( QH("1 AA 2 B 3 CCC 4 DD 5 Z").
    RemoveWXTQ('{ Q(@Char).IsNumberInString() }').
    RemoveSpacesQ().
    RemoveDuplicatedCharsQ().
    History() )

#--> [
#	"1 AA 2 B 3 CCC 4 DD 5 Z",      # Original
#	" AA  B  CCC  DD  Z",           # After removing numbers
#	"AABCCCDDZ",                    # After removing spaces
#	"ABCDZ"                         # Final result
# ]
```

Yet an other example around numbers:

```ring
? Q(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	Value()

	#--> 45

? @@( Qh(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	History() )

	#--> [ 13000, 11500, 23, 46 ]
```

>**NOTE 1**: All other Softanza objects—not just `stzString` and `stzNumber`, as demonstrated—are supported and can retain their historic values. This includes `stzList`s, `stzObject`s, `stzTable`s, and more.

>**NOTE 2**: `**@@**(val)` is a Softanza small function, akin to a **pair of glasses** that enhance vision, designed to produce a readable string representation of any value `val`. Specifically, when `val` is a list, it is rendered with brackets ([, ]) and commas (,), like you see in `[ 13000, 11500, 23, 46 ]` above, accurately representing the list structure regardless of its depth.


## Key Benefits

- **Debugging Insight**: Trace exactly how your data transformed
- **Educational Tool**: Visualize complex manipulation processes
- **Audit Trail**: Maintain a comprehensive log of object mutations

---

## Conclusion

Softanza turns data transformation from a black box into a transparent, narratable journey.

