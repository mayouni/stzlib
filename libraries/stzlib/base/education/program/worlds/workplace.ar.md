# المطعم

بيلا كوتشينا، مطعم صغير، والعالم الذي يعمل عليه هذا المقرر ما لم تختر غيره. يتلقى المطبخ طلبيات؛ كل طلبية تطلب
طبقًا، والأطباق تحتوي على مكونات. هذه الصفحة هي العالم نفسه مسؤولًا: كل خلية تعمل على `worlds/workplace.zknw`،
الملف البسيط الذي تستدل عليه الفصول، والصفحة لا تخزّن شيئًا.

## 1. اسمه

أول ما يقوله العالم هو ما هو.

```ring
? EduWorldName()
#--> bella-cucina (restaurant)
```

## 2. ما طُلب

وصلت ست طلبيات اليوم. بعضها يطلب الطبق نفسه، ولهذا يزيل الفصل 1 المكررات ويعدّ الفصل 5 الأكثر طلبًا.

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

## 3. ما يحتويه الطبق

يعرف العالم أكثر من الطلبيات: ما يحتويه كل طبق، وأي طبق يحتوي على مكوّن معيّن.

```ring
? @@( EduWorld().Query([ "margherita", "contains", "?what" ]) )
#--> [ "tomato", "mozzarella" ]
? @@( EduWorld().Query([ "?dish", "contains", "beef" ]) )
#--> [ "lasagna" ]
? @@( EduWorld().Query([ "tiramisu", "contains", "?what" ]) )
#--> [ "mascarpone" ]
```

## 4. سؤال لا يستطيع الإجابة عنه بعد

من طلب اللازانيا؟ يقول العالم ما طلبته كل طلبية، لكن لا من قدّمها، فالجواب فارغ لا تخمين. يبيّن الفصل 12 كيف
تضيف الحقيقة الناقصة؛ ويبيّن الفصل 13 كيف تسألك سوفتانزا عن فجوة كهذه.

```ring
? @@( EduWorld().Query([ "?who", "placed", "order-4" ]) )
#--> [ ]
```
