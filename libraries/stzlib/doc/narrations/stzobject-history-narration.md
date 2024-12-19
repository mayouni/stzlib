# The Narrative of Transformations: Tracking Object History in Softanza
![Tracking Object History in Softanza, by Microsoft Image Create AI](../images/stzobject-history.jpg)


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

>**NOTE 1**: All other Softanza objects—not just `stzString` and `stzNumber`, as demonstrated—are supported and can retain their historic values. This includes `stzList`, `stzObjects`, `stzTable`, and more.

>**NOTE 2**: `@@(val)` is a Softanza small function, akin to a **pair of glasses** that enhance vision, designed to produce a readable string representation of any value `val`. Specifically, when `val` is a list, it is rendered with brackets ([, ]) and commas (,), like you see in `[ 13000, 11500, 23, 46 ]` above, accurately representing the list structure regardless of its depth.


## Cherry on the Cake: More Information with the `QHH()` Small Function

By adding an extra `H` suffix to `QH()`, Softanza reveals all its secrets and informs us not only about the updated values in the chain but also their **types** and **execution times**.

To demonstrate this, let’s use a more elaborate example that takes some time to execute. Hence, the chain of actions starts with the word "LIFE" and ends with the word `"L ♥ F E"`:

```ring
? Q("LIFE").
	LowercaseQ().
	SpacifyQ().

	CharsQ().
	RemoveSpacesQ().
	UppercaseQ().

	JoinQ().
	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).

	Content() + NL
	#--> L ♥ F E
```

Let’s add the `H()` suffix, as shown previously, to observe the updated values:

```ring
? @@NL(
	QH("LIFE").
	LowercaseQ().
	SpacifyQ().
	CharsQ().
	RemoveSpacesQ().
	UppercaseQ().
	JoinQ().
	SpacifyQ().
	ReplaceQ("I", :With = AHeart()).
	History()
)

#--> [
#	"LIFE",
#	"life",
#	"l i f e",
#
#	[ "l", "i", "f", "e" ],
#	[ "L", "I", "F", "E" ],
#	[ "L", "I", "F", "E" ],
#
#	"L I F E",
#	"L ♥ F E"
# ]
```

Now, instead of using just `H()`, we use a double `HH()` suffix to obtain more information about the types of intermediate objects updated, the execution time taken by each update, and their size in megabytes within the Ring VM.

```ring
? @@NL(
	QHH("LIFE").
	LowercaseQ().
	SpacifyQ().
	CharsQ().

	RemoveSpacesQ().
	LoopNTimesQ(100_000). # Just to add time add see it traced
	UppercaseQ().
	JoinQ().

	SpacifyQ().
	LoopNTimesQ(100_000).
	ReplaceQ("I", :With = AHeart()).
	History()
)

#--> [
#	[ "LIFE", "stzstring", 0, 435 ],
#	[ "life", "stzstring", 0.02, 435 ],
#	[ "l i f e", "stzstring", 0.04, 435 ],
#
#	[ [ "l", " ", "i", " ", "f", " ", "e" ], "stzlist", 0, 322 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 0, 319 ],
#	[ [ "l", "i", "f", "e" ], "stzlist", 0.01, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0.01, 319 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0, 319 ],
#
#	[ "LIFE", "stzstring", 0, 435 ],
#	[ "L I F E", "stzstring", 0.02, 435 ],
#
#	[ [ "with", "♥" ], "stzlist", 0, 322 ],
#
#	[ "L ♥ F E", "stzstring", 0.01, 435 ]
# ]
```

Here's a detailed explanation of what happened in the code execution:

- Started with `"LIFE"` as a `stzString` object, initial size `435 bytes`
- Converted to lowercase `"life"`, taking almost `0s`, maintaining same size of `435 bytes`
- Added spaces between chars `"l i f e"`, taking almost `0s`, maintaining same size of `435 bytes`

- Transformed to a list of characters `["l", " ", "i", " ", "f", " ", "e"]`, becoming a `stzlist` object, taking `0.02s`, with a size of `322 bytes`
- Removed spaces from the list `["l", "i", "f", "e"]`, taking `0.02s`, witht a size of `319 bytes`
- Converted all characters of the list to uppercase `["L", "I", "F", "E"]`, taking `0.03s`, and maintaining the same size of `319 bytes`

- Joined the list back into a string `"LIFE"`, converting back to `stzstring`, taking almost `0s`, with the size of `435 bytes`
- Added spaces between characters `"L I F E"`, inside the same `stzString` object, taking almost `0s`, and maintaining the same size of `435 bytes`
- Replaced the `"I"` in `"LIFE"` with a heart character, taking taking almost `0s`, and maintaining the same size of `435 bytes`

The operations alternated between `stzstring` and `stzlist` objects, with strings opeations beeing faster (due to the use of Qt C++ internally), while lists generally having smaller memory footprints. Most operations completed very quickly, with only a few taking measurable time.


>**NOTE**: The `@@NL()` small function generates a readable string representation of the list, just like `@@()`, but with the added distinction of displaying each item on a separate line.

## Key Benefits

The `QH()` and `QHH()` small functions may appear *small*, but they have *big* impacts:

- **Debugging Insight**: Trace exactly how your data transformed, making it easier to pinpoint issues during data processing or model training.

- **Educational Tool**: Visualize complex manipulation processes, helping to understand how data is processed at each stage.

- **Audit Trail**: Maintain a comprehensive log of object mutations, ensuring transparency and compliance in workflows.

- **Data Analytics Pipelines**: Track data transformations through each step, aiding in debugging, model evaluation, and reproducibility.

- **Business Workflows**: Provide visibility into how data flows through business processes, helping to identify inefficiencies and improve decision-making

---

## Conclusion

Thanks to its thoughtful design centered around visibility, clarity, and explainability of code, Softanza transforms data processing from a black box into a transparent, narratable journey.

