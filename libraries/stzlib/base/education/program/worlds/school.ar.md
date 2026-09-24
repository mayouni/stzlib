# المدرسة

مدرسة ثانوية في نيامي. تأتي الأسر والتلاميذ إلى المكتب طلبًا لكشوف الدرجات والكتب المدرسية ومقعد في صف وشهادات.
هذه الصفحة هي العالم نفسه مسؤولًا: كل خلية تعمل على `worlds/school.zknw`، الملف البسيط الذي تستدل عليه الفصول حين
تختار هذا العالم، والصفحة لا تخزّن شيئًا.

## 1. اسمه

أول ما يقوله العالم هو ما هو.

```ring
? EduWorldName()
#--> lycee-de-niamey (school)
```

## 2. ما طُلب

وصل سبعة طلبات إلى المكتب هذا الأسبوع. بعضها يطلب الشيء نفسه، ولهذا يزيل الفصل 1 المكررات ويعدّ الفصل 5 الأكثر طلبًا.

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

## 3. أي مادة، أي صف

يعرف العالم أكثر من الطلبات: أي مادة تُدرَّس في أي صف، ومن يقود كل صف.

```ring
? @@( EduWorld().Query([ "?subject", "taught-in", "class-3a" ]) )
#--> [ "mathematics", "physics" ]
? @@( EduWorld().Query([ "history", "taught-in", "?class" ]) )
#--> [ "class-3b" ]
? @@( EduWorld().Query([ "class-3b", "led-by", "?who" ]) )
#--> [ "m-issoufou" ]
```

## 4. سؤال لا يستطيع الإجابة عنه بعد

من يدرّس التاريخ؟ يقول العالم في أي صف يُدرَّس التاريخ ومن يقود ذلك الصف، لكن لا من يدرّس المادة، فالجواب فارغ
لا تخمين. يبيّن الفصل 12 كيف تضيف الحقيقة الناقصة؛ ويبيّن الفصل 13 كيف تسألك سوفتانزا عن فجوة كهذه.

```ring
? @@( EduWorld().Query([ "history", "taught-by", "?who" ]) )
#--> [ ]
```
