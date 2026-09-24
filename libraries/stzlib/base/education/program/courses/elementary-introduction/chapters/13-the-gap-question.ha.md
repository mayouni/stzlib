# Tambayar giɓi

*Gabatarwa ta Farko · Babi na 13 · Fasahohi KN-03 "Me Softanza ta tambaye ni, kuma me ya sa?" da KN-04 "Me ɗakin karatu ke kiran abin da nake nufi?"*

> Fassarar farko ce, tana jiran bita daga mai magana da Hausa a matsayin harshen uwa.

Buƙata mara tsari tana samun zato daga yawancin tsare-tsare. Softanza tana tambaya maimakon haka. Ka
bayyana abin da cikakkiyar duniya dole ta ƙunsa, kuma giɓin da ke tsakanin wannan manufar da duniyar yana
zama tambaya ta gaba, da dalilinta. Wannan babin kuma yana juya wannan tunanin ga ɗakin karatu da kansa:
ka tambaye shi abin da yake kiran abin da kake nufi.

## 1. Bayyana manufa

Kowane abinci dole ne ya faɗi abin da yake ɗauke da shi. Abinci biyu, babu abin da aka rubuta: giɓi biyu.

```ring
oRest = new stzKnowledgeGraph("restaurant")
oRest.Know("margherita", "dish").Know("tiramisu", "dish")
oRest.AddConversationQ("setup").SetGoal(StzGoalQ().RequireEach("dish", "contains"))
? len( oRest.GapsIn("setup") )
#--> 2
```

## 2. Softanza tana tambaya, ta faɗi dalili

```ring
aQ = oRest.AskInXT("setup")
? aQ[:question]
#--> What does 'margherita' have for 'contains'?  (why: every dish needs 'contains')
```

## 3. Ka amsa da kalmomi, duniyar ta girma

```ring
aV = oRest.ReplyIn("setup", "tomato and mozzarella")
? @@( aV[:admitted] )
#--> [ "tomato", "mozzarella" ]
? @@( oRest.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato", "mozzarella" ]
? len( oRest.GapsIn("setup") )
#--> 1
```

## 4. Tambaya ta gaba tana ba da abin da ta riga ta sani

```ring
aQ2 = oRest.AskInXT("setup")
? aQ2[:question]
#--> Which 'contains' does 'tiramisu' have? (1) tomato  (2) mozzarella -- or answer freely.  (why: every dish needs 'contains')
```

## 5. Tambayi ɗakin karatu abin da yake kiran abin da kake nufi

Ɗakin karatu yana kwatanta kansa. `HowTo` yana mai da nufi kira, ya faɗi yadda ya kai ga hakan.

```ring
oDoc = StzSelfDocQ("stzList")
? oDoc.HowTo("remove duplicates")
#--> Q([...]).RemoveDuplicates()   -- composed by grammar (remove duplicates)
? oDoc.HasMethod("DuplicatesRemoved")
#--> TRUE
```

## 6. Bayyana hanya, ka ƙi wadda ba a sani ba

```ring
? StzLeft( oDoc.ExplainMethod("DuplicatesRemoved"), 20 )
#--> DuplicatesRemoved --
? oDoc.ExplainMethod("NoSuchThing")
#--> No method 'NoSuchThing' in stzList.
```

{{exercise:ex-13-01}}

{{exercise:ex-13-02}}

## Taƙaitawa

- **Abin da ka cimma:** ka bayyana manufa, ka karɓi tambayar giɓi da dalilinta, ka amsa da kalmomi, ka ga
  tambaya ta gaba tana ba da abin da aka sani, ka roƙi ɗakin karatu ya sa wa hanya suna daga nufinka.
- **Me ya sa yake da muhimmanci:** tsarin da yake tambaya yana koya maka abin da cikakken samfuri ke buƙata.
  Tsarin da yake zato yana ɓoye shi.
- **Abin da ke tafe:** wakili wanda yake ba da shawara amma ba zai iya aiki ba.
