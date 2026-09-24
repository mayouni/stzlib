# التعاونية

تعاونية زراعية في سهل تيلابيري. يجلب أعضاؤها ما يزرعونه، ويطلبون من التعاونية البذور والسماد والقرض ومكانًا لتخزين
المحصول. هذه الصفحة هي العالم نفسه مسؤولًا: كل خلية تعمل على `worlds/cooperative.zknw`، الملف البسيط الذي تستدل عليه
الفصول حين تختار هذا العالم، والصفحة لا تخزّن شيئًا.

## 1. اسمه

أول ما يقوله العالم هو ما هو.

```ring
? EduWorldName()
#--> tillaberi-cooperative (cooperative)
```

## 2. ما طُلب

وصل سبعة طلبات هذا الموسم. بعضها يطلب الشيء نفسه، ولهذا يزيل الفصل 1 المكررات ويعدّ الفصل 5 الأكثر طلبًا.

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

## 3. من يزرع ماذا

يعرف العالم أكثر من الطلبات: أي عضو يزرع أي محصول، وأين يُخزَّن كل محصول.

```ring
? @@( EduWorld().Query([ "?who", "grows", "millet" ]) )
#--> [ "amadou", "issa" ]
? @@( EduWorld().Query([ "hadiza", "grows", "?what" ]) )
#--> [ "cowpea" ]
? @@( EduWorld().Query([ "cowpea", "stored-in", "?where" ]) )
#--> [ "granary-2" ]
```

## 4. سؤال لا يستطيع الإجابة عنه بعد

من طلب القرض؟ لا يقول العالم من قدّم كل طلب، فالجواب فارغ لا تخمين. يبيّن الفصل 12 كيف تضيف الحقيقة الناقصة؛
ويبيّن الفصل 13 كيف تسألك سوفتانزا عن فجوة كهذه.

```ring
? @@( EduWorld().Query([ "hadiza", "requested", "?what" ]) )
#--> [ ]
```
