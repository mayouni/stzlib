# Say it in your language

*Elementary Introduction · Chapter 4 · Skill EX-05: "Can I say this program in my own language and have it run?"*

Softanza understands a program written as a sentence, in more than one human language. This is not a
translation of the page: the sentence itself is the program, and it runs. Every cell below runs in every
edition of this chapter, whatever language you are reading it in.

## 1. The languages Softanza speaks today

```ring
? @@( StzNaturalLanguages() )
#--> [ "en", "ha", "fr", "ar", "tr" ]
```

## 2. English

`Understood()` says back what Softanza took the sentence to mean, so you can check it before you trust
the result.

```ring
oN = Naturally("Create a list with [ 4, 4, 9 ] and remove its duplicates")
? @@( oN.Result() )
#--> [ 4, 9 ]
? oN.Understood()
#--> create a list with [ 4, 4, 9 ] -> remove duplicates
```

## 3. French

```ring
oF = NaturallyIn("fr", "Crée une liste avec [ 4, 4, 9 ] et enlève les doublons")
? @@( oF.Result() )
#--> [ 4, 9 ]
? oF.Understood()
#--> crée liste avec [ 4, 4, 9 ] -> enlève les doublons
```

## 4. Arabic

```ring
oA = NaturallyIn("ar", "أنشئ قائمة مع [ 4, 4, 9 ] أزل التكرارات")
? @@( oA.Result() )
#--> [ 4, 9 ]
? oA.Understood()
#--> أنشئ قائمة بـ [ 4, 4, 9 ] -> أزل التكرارات
```

## 5. Hausa

```ring
oH = NaturallyIn("ha", "Yi jeri dauke [ 4, 4, 9 ] cire maimaitattu")
? @@( oH.Result() )
#--> [ 4, 9 ]
? oH.Understood()
#--> yi jeri dauke [ 4, 4, 9 ] -> cire maimaitattu
```

## 6. When it does not understand, it says which word

Softanza never guesses. A sentence it cannot resolve is reported word by word, with the nearest word it
does know.

```ring
? @@( StzNaturalLintIn("fr", "Crée une liste avec [ 4, 4, 9 ] et danse la salsa") )
#--> [ [ "understood", 0 ], [ "unresolved", [ [ "danse", "" ], [ "salsa", "sans" ] ] ] ]
```

{{exercise:ex-04-01}}

## Recap

- **Achieved:** you ran the same program as a sentence in four languages, read back what was understood,
  and saw a sentence refused word by word instead of guessed.
- **Why it matters:** a learner's first language is a programming language here. Nothing is lost between
  the way you think and the way you write.
- **Coming next:** the three questions of chapter 1, asked of a string, a list, and anything else.
