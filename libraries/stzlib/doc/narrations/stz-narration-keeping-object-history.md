# The Narrative of Transformations: Tracking Object History in Softanza
![Tracking Object History in Softanza](images/stz-narration-keeping-object-history.jpg)

----

## Unveiling the Story Behind Data Mutations

In programming, data transformations often happen in the blink of an eye, leaving no trace of their journey. Softanza challenges this paradigm with a groundbreaking feature that captures the entire lifecycle of object modifications.

---

## The Initial Approach: Transformation Without History

Consider this basic string transformation chain in Softanza:

```ring
load "stzlib.ring"

? Q("1 AA 2 B 3 CCC 4 DD 5 Z").
    RemoveWXTQ('{ Q(@Char).IsNumberInString() }').
    RemoveSpacesQ().
    RemoveDuplicatedCharsQ().
    Content() + NL
#--> ABCDZ
```

Here, we process the string, removing numbers, spaces, and duplicate characters. The result is clear, but the path is forgotten.

---

## The Challenge: Preserving the Transformation Trail

What if we could capture each step of this transformation? Imagine a programming feature that doesn't just give you the final result, but tells you the entire story of how that result was achieved.

---

## The Solution: Introducing `QH()` small function

```ring
? @@NL( QH("1 AA 2 B 3 CCC 4 DD 5 Z").
    RemoveWXTQ('{ Q(@Char).IsNumberInString() }').
    RemoveSpacesQ().
    RemoveDuplicatedCharsQ().
    History() ) + NL
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

>NOTE: All other Softanza objects—not just `stzString`s and `stzNumber`s, as demonstrated—are supported and can retain their historic values. This includes `stzList`s, `stzObject`s, `stzTable`s, and more.

---

## Key Benefits

- **Debugging Insight**: Trace exactly how your data transformed
- **Educational Tool**: Visualize complex manipulation processes
- **Audit Trail**: Maintain a comprehensive log of object mutations

Softanza turns data transformation from a black box into a transparent, narratable journey.

