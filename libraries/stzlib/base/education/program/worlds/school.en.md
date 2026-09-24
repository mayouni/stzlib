# The school

A secondary school in Niamey. Families and pupils come to the office for transcripts, textbooks, a place
in a class and certificates. This page is the world itself, questioned: every cell runs over
`worlds/school.zknw`, the plain file the chapters reason over when you choose this world, and the page
stores nothing.

## 1. Its name

The first thing a world says is what it is.

```ring
? EduWorldName()
#--> lycee-de-niamey (school)
```

## 2. What was requested

Seven requests reached the office this week. Some ask for the same thing, which is why chapter 1 removes
the duplicates and chapter 5 counts the most requested.

```ring
aReq = EduWorldObjects("requested")
? len(aReq)
#--> 7
? @@( aReq )
#--> [ "transcript", "textbook", "transcript", "enrolment", "certificate", "textbook", "transcript" ]
o1 = new stzList(aReq)
? @@( o1.DuplicatesRemoved() )
#--> [ "transcript", "textbook", "enrolment", "certificate" ]
? StzListQ(aReq).NumberOfOccurrence("transcript")
#--> 3
```

## 3. Which subject, which class

The world knows more than requests: which subject is taught in which class, and who leads each class.

```ring
? @@( EduWorld().Query([ "?subject", "taught-in", "class-3a" ]) )
#--> [ "mathematics", "physics" ]
? @@( EduWorld().Query([ "history", "taught-in", "?class" ]) )
#--> [ "class-3b" ]
? @@( EduWorld().Query([ "class-3b", "led-by", "?who" ]) )
#--> [ "m-issoufou" ]
```

## 4. A question it cannot answer yet

Who teaches history? The world says which class history is taught in and who leads that class, but not
who teaches the subject, so the answer is empty, not a guess. Chapter 12 shows how you add the missing
fact; chapter 13 shows how Softanza asks you about a gap like this one.

```ring
? @@( EduWorld().Query([ "history", "taught-by", "?who" ]) )
#--> [ ]
```
