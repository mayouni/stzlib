# Makaranta

Makarantar sakandare a Yamai. Iyalai da ɗalibai suna zuwa ofis don neman takardar sakamako, littattafai, wuri a aji
da shaidar karatu. Wannan shafin duniyar kanta ce, an tambaye ta: kowane ɗaki yana gudana a kan `worlds/school.zknw`,
fayil mai sauƙi da babobin ke tunani a kai idan ka zaɓi wannan duniyar, kuma shafin ba ya ajiye komai.

## 1. Sunanta

Abu na farko da duniya take faɗa shi ne abin da take.

```ring
? EduWorldName()
#--> lycee-de-niamey (school)
```

## 2. Abin da aka nema

Buƙatu bakwai sun isa ofis a wannan makon. Wasu suna neman abu ɗaya, shi ya sa babi na 1 yake cire maimaitattu
kuma babi na 5 yake ƙidaya abin da aka fi nema.

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

## 3. Wane darasi, wane aji

Duniyar ta san fiye da buƙatu: wane darasi ake koyarwa a wane aji, kuma wa yake jagorantar kowane aji.

```ring
? @@( EduWorld().Query([ "?subject", "taught-in", "class-3a" ]) )
#--> [ "mathematics", "physics" ]
? @@( EduWorld().Query([ "history", "taught-in", "?class" ]) )
#--> [ "class-3b" ]
? @@( EduWorld().Query([ "class-3b", "led-by", "?who" ]) )
#--> [ "m-issoufou" ]
```

## 4. Tambayar da ba za ta iya amsawa ba tukuna

Wa yake koyar da tarihi? Duniyar tana faɗa a wane aji ake koyar da tarihi da kuma wa yake jagorantar ajin, amma ba
wa yake koyar da darasin ba, don haka amsar babu kome, ba tsammani ba. Babi na 12 yana nuna yadda ake ƙara gaskiyar
da ta ɓace; babi na 13 yana nuna yadda Softanza take tambayarka game da giɓi irin wannan.

```ring
? @@( EduWorld().Query([ "history", "taught-by", "?who" ]) )
#--> [ ]
```
