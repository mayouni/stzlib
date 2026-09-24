# Ƙungiyar haɗin gwiwa

Ƙungiyar manoma ta haɗin gwiwa a filin Tillaberi. Membobinta suna kawo abin da suke nomawa, kuma suna neman iri,
taki, bashi da wurin ajiyar amfani daga ƙungiyar. Wannan shafin duniyar kanta ce, an tambaye ta: kowane ɗaki yana
gudana a kan `worlds/cooperative.zknw`, fayil mai sauƙi da babobin ke tunani a kai idan ka zaɓi wannan duniyar, kuma
shafin ba ya ajiye komai.

## 1. Sunanta

Abu na farko da duniya take faɗa shi ne abin da take.

```ring
? EduWorldName()
#--> tillaberi-cooperative (cooperative)
```

## 2. Abin da aka nema

Buƙatu bakwai sun zo a wannan kakar. Wasu suna neman abu ɗaya, shi ya sa babi na 1 yake cire maimaitattu kuma
babi na 5 yake ƙidaya abin da aka fi nema.

```ring
aReq = EduWorldObjects("requested")
? len(aReq)
#--> 7
? @@( aReq )
#--> [ "seed", "fertiliser", "seed", "credit", "storage", "seed", "credit" ]
o1 = new stzList(aReq)
? @@( o1.DuplicatesRemoved() )
#--> [ "seed", "fertiliser", "credit", "storage" ]
? StzListQ(aReq).NumberOfOccurrence("seed")
#--> 3
```

## 3. Wa yake noma me

Duniyar ta san fiye da buƙatu: wane memba yake noma wace amfani, kuma ina ake ajiye kowace amfani.

```ring
? @@( EduWorld().Query([ "?who", "grows", "millet" ]) )
#--> [ "amadou", "issa" ]
? @@( EduWorld().Query([ "hadiza", "grows", "?what" ]) )
#--> [ "cowpea" ]
? @@( EduWorld().Query([ "cowpea", "stored-in", "?where" ]) )
#--> [ "granary-2" ]
```

## 4. Tambayar da ba za ta iya amsawa ba tukuna

Wa ya nemi bashi? Duniyar ba ta faɗa wa ya yi kowace buƙata ba, don haka amsar babu kome, ba tsammani ba. Babi
na 12 yana nuna yadda ake ƙara gaskiyar da ta ɓace; babi na 13 yana nuna yadda Softanza take tambayarka game da giɓi
irin wannan.

```ring
? @@( EduWorld().Query([ "hadiza", "requested", "?what" ]) )
#--> [ ]
```
