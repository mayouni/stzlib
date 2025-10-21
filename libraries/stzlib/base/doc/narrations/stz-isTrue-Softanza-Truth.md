### **Softanza Embraces Ring’s Truth — and Extends It Gracefully**

In Ring, *truth* is pure and direct — a language-level agreement between logic and simplicity.
An empty string is **false**, a non-empty one is **true**. An empty list is **false**, while a non-empty list is **true**. Objects, by their very existence, are **true**.

This clarity makes Ring remarkably natural. You can almost *feel* the interpreter thinking as you would:

> “If there’s nothing, it’s false. If there’s something, it’s true.”

Such simplicity is the beauty of Ring — a **philosophy of presence**.

---

Softanza, however, grows on this fertile soil. It does not replace Ring’s truth — it **embraces it** — but adds a **layer of configuration** to cope with the complexity of real-world settings, where truth can be nuanced, contextual, or even conditional.

By default, Softanza’s `IsTrue()` and `IsFalse()` behave exactly like Ring’s native logic. The standard holds:

```ring
? IsTrue("")       # FALSE  
? IsTrue([])       # FALSE  
? IsTrue(["Hi"])   # TRUE  
```

But then comes the *eXtended Truth* — `IsTrueXT()` — a mode of reasoning that adapts to configuration and semantics.
Here, an *empty list* may or may not be considered false, depending on global rules:

```ring
SetEmptyListIsConsideredFalse(:No)
? IsTrueXT([])   # Now TRUE
```

Truth becomes a **matter of policy** — something the system can **decide** or **negotiate**, instead of being frozen in syntax.

---

Softanza goes further. Words themselves can carry falsity within them.
By defining substrings that “falsify” a string, one can encode meaning directly into content:

```ring
SetSubStringsMakingAStringFalse(["false", "wrong", "dangerous"])
? IsTrueXT("this is dangerous and should be false")   # FALSE
```

Thus, a string’s truth isn’t just about whether it exists, but *what it contains*.
Language meets logic.

Lists follow the same philosophy. You can define items — or even inner items — that make an entire list **false**:

```ring
SetItemsMakingAListFalse(["false", "wrong", "dangerous"])
? IsTrueXT(["hello", "this", "is", "wrong"])   # FALSE
? IsTrue(["hello", "this", "is", "wrong"])     # TRUE
```

And when the logic needs to go deeper — into lists nested within lists —
Softanza allows inner items to be defined as falsifying elements too:

```ring
SetInnerItemsMakingAListFalse(["X"])
? @@( InnerItemsMakingAListFalse() )
#--> [ "X" ]

# DeepContains still reports that "X" exists down inside the nested list
? DeepContains([ 1, 2, [ 3, "X", 4 ], 5 ], "X")
#--> TRUE

# Because "X" is declared an inner-item that falsifies the list,
# the extended truth check returns FALSE for the whole structure:
? IsTrueXT([ 1, 2, [ 3, "X", 4 ], 5 ])
#--> FALSE

# If you later disable inner-item falsification, the same structure becomes TRUE again:
SetInnerItemsMakingAListFalse(:No)
? IsTrueXT([ 1, 2, [ 3, "X", 4 ], 5 ])
#--> TRUE
```

Here, the presence of `"X"` inside the nested list falsifies the overall structure —
a form of deep semantic awareness that lets the developer control how truth propagates within data.

---

### **Practical Implications — Ethics, Language, and Safety**

This configurable notion of truth is not just theoretical. It becomes a **foundation for semantic filtering**, **ethic safety**, and **automatic moderation** inside applications.

Softanza provides a predefined list of **stop words** — neutral, negative, or ethically sensitive terms — through the function `StopWords()`.
By linking it directly to the truth configuration, developers can instantly build moral safeguards into their systems:

```ring
SetSubStringsMakingAStringFalse( StopWords() )

? IsTrueXT("this comment is offensive and wrong")
#--> FALSE
```

With a single line, the app now *recognizes falsity in meaning*, not just in form.
A comment, a label, a field, or a user input can be evaluated not only by its existence, but by its **semantic integrity**.

This principle extends naturally:

* A moderation engine that rejects texts containing harmful language.
* A quality-check tool that filters invalid datasets by meaning.
* A dialogue system that avoids spreading toxicity or misinformation.

In each case, the same mechanism — `IsTrueXT()` combined with configurable substrings — serves as an **ethical layer**, ensuring that what the system considers “true” aligns with the values defined by its designers.

---

Softanza thus transforms truth from a *syntactic rule* into a *semantic conscience*.
Where Ring defines what **is**, Softanza helps decide what **should be allowed to stand as true** —
a small but powerful step toward **responsible logic** in code.
