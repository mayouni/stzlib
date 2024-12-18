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
	Content()

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
#	[ "l", "i", "f", "e" ],
#	[ "L", "I", "F", "E" ],
#	"L I F E",
#	"L ♥ F E"
# ]
```

Now, instead of just `H()`, we use a double `HH()` suffix to get more information about the types of intermediate objects updated and the execution time **each update** takes:

```ring
decimals(3) # Set precision to 3 decimal places to display execution time accurately

? @@NL(
	QHH("LIFE").
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
#	[ "LIFE", "stzstring", 0 ],
#	[ "life", "stzstring", 0 ],
#	[ "l i f e", "stzstring", 0.001 ],

#	[ [ "l", "i", "f", "e" ], "stzlist", 0.001 ],
#	[ [ "L", "I", "F", "E" ], "stzlist", 0.001 ],

#	[ "L I F E", "stzstring", 0.002 ],
#	[ "L ♥ F E", "stzstring", 0.002 ]
# ]
```

This is what we can infer from the output:

- The process starts with the string `LIFE` in a `stzstring` object, taking no time.

- It is converted to **lowercase** (`life`) within the same `stzstring` object, with no measurable time.

- **Spaces** are added between the characters, changing the `stzstring` content to `"l i f e"` in `1 ms`.

- The string is transformed into a list of **chars** `[ "l", "i", "f", "e" ]`, stored in a `stzlist` object, taking another `1 ms` (cumulative time becomes `2 ms`).

- The characters are converted to **uppercase **`[ "L", "I", "F", "E" ]`, updating the `stzlist` content in nearly `0 ms` (cumulative time remains `2 ms`).

- The list is joined back into `LIFE` in a `stzstring` object. Note that this action **doesn’t update the content**, as it merely transforms data between types, and thus **is not traced**.

- **Spaces** are added again, making the `stzstring` content `L I F E` in nearly `1 ms` (cumulative time becomes `3 ms`).

- Finally, `I` is **replaced** with a heart symbol, updating the `stzstring` object to `L ♥ F E` in nearly `0 ms` (closing all the executaion time at `3 ms`).


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

