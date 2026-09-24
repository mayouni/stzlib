# Gidan abinci

Bella Cucina, ƙaramin gidan abinci, kuma duniyar da wannan darasin ke gudana a kai sai dai idan ka zaɓi wata. Ɗakin
girki yana karɓar oda; kowace oda tana neman abinci ɗaya, kuma abinci yana ɗauke da kayan haɗi. Wannan shafin duniyar
kanta ce, an tambaye ta: kowane ɗaki yana gudana a kan `worlds/workplace.zknw`, fayil mai sauƙi da babobin ke tunani a
kai, kuma shafin ba ya ajiye komai.

## 1. Sunanta

Abu na farko da duniya take faɗa shi ne abin da take.

```ring
? EduWorldName()
#--> bella-cucina (restaurant)
```

## 2. Abin da aka nema

Oda shida sun zo yau. Wasu suna neman abinci ɗaya, shi ya sa babi na 1 yake cire maimaitattu kuma babi na 5 yake
ƙidaya abin da aka fi nema.

```ring
aReq = EduWorldObjects("requested")
? len(aReq)
#--> 6
? @@( aReq )
#--> [ "margherita", "tiramisu", "margherita", "lasagna", "tiramisu", "margherita" ]
o1 = new stzList(aReq)
? @@( o1.DuplicatesRemoved() )
#--> [ "margherita", "tiramisu", "lasagna" ]
? StzListQ(aReq).NumberOfOccurrence("margherita")
#--> 3
```

## 3. Abin da abinci ya ƙunsa

Duniyar ta san fiye da oda: abin da kowane abinci ya ƙunsa, kuma wane abinci ya ƙunshi wani kayan haɗi.

```ring
? @@( EduWorld().Query([ "margherita", "contains", "?what" ]) )
#--> [ "tomato", "mozzarella" ]
? @@( EduWorld().Query([ "?dish", "contains", "beef" ]) )
#--> [ "lasagna" ]
? @@( EduWorld().Query([ "tiramisu", "contains", "?what" ]) )
#--> [ "mascarpone" ]
```

## 4. Tambayar da ba za ta iya amsawa ba tukuna

Wa ya yi odar lasagna? Duniyar tana faɗa abin da kowace oda ta nema, amma ba wa ya yi ta ba, don haka amsar babu
kome, ba tsammani ba. Babi na 12 yana nuna yadda ake ƙara gaskiyar da ta ɓace; babi na 13 yana nuna yadda Softanza
take tambayarka game da giɓi irin wannan.

```ring
? @@( EduWorld().Query([ "?who", "placed", "order-4" ]) )
#--> [ ]
```
