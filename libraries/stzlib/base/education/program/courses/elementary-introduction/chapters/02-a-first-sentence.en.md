# A first sentence

*Elementary Introduction · Chapter 2 · Skills FO-01 "What am I really asking?" and EX-01 "Which object holds my data?"*

In chapter 1 the requests came as a list. Today they come as a sentence: a customer's complaint. Before any
code, the mental model asks you to say the problem in words and pull out its keywords, because the keywords
name the object you will select.

## 1. Say the problem

*"Does this complaint repeat a word, and which one?"*

Three keywords. **Complaint** is a text, so the object is a `stzString`. **Word** is something a string can
give you. **Repeat** is a question about duplicates, and duplicates live in a list.

## 2. Select the object

```ring
o1 = new stzString("the bread was cold and the tea was cold")
? o1.NumberOfWords()
#--> 9
```

## 3. Ask the string for its words

```ring
? @@( o1.Words() )
#--> [ "the", "bread", "was", "cold", "and", "the", "tea", "was", "cold" ]
```

## 4. The keyword "repeat" belongs to a list

The words are a list now, so the questions of chapter 1 apply to them unchanged.

```ring
oW = new stzList( o1.Words() )
? oW.ContainsDuplicates()
#--> TRUE
? oW.NumberOfDuplicates()
#--> 3
```

## 5. Find, then apply

```ring
? @@( oW.FindDuplicates() )
#--> [ 6, 8, 9 ]
? @@( oW.DuplicatesRemoved() )
#--> [ "the", "bread", "was", "cold", "and", "tea" ]
```

## 6. Your workplace, as a sentence

The requests your workplace received today, joined into one sentence. What it prints depends on the world
this course runs over, so run it.

```ring
aReq = EduWorldObjects("requested")
? Q(aReq).Joined(", ")
? Q( Q(aReq).Joined(" ") ).NumberOfWords()
```

{{exercise:ex-02-01}}

## Recap

- **Achieved:** you said a problem in words, took its keywords, and let them choose the object: a string
  for the complaint, a list for the repeated words.
- **Why it matters:** the object you select decides which questions you can ask. A string answers "how many
  words"; a list answers "which are repeated".
- **Coming next:** the names of the questions themselves are sentences. The next chapter teaches you to read
  them.
