# علّم عالمًا

*مدخل أساسي · الفصل 12 · المهارتان KN-01 «ماذا يعرف مكان عملي، وكيف أكتبه؟» وKN-02 «ماذا يترتب على ما كتبته؟»*

> ترجمة أولية، في انتظار مراجعة متحدث أصلي.

لا تعرف سوفتانزا شيئًا عن مطعمك أو بنكك أو مدرستك حتى تخبرها. **العالم** هو ما تخبرها به: حقائق، تُكتب كل
واحدة في ثلاث كلمات، وبضعة قوانين عن العلاقات بينها. وما إن يوجد عالم حتى تستطيع سوفتانزا أن تجيب عن
أسئلة فوقه، وتثبت الأجوبة.

## 1. صرّح بالحقائق

الحقيقة *فاعل، علاقة، مفعول*. `Know` تقول ما الشيء؛ و`KnowRelation` تقول أي علاقة أخرى.

```ring
oKB = new stzKnowledgeGraph("menu")
oKB.Know("margherita", "dish").Know("tiramisu", "dish").Know("pizza", "dish")
oKB.KnowRelation("margherita", "kind-of", "pizza")
oKB.KnowRelation("pizza", "kind-of", "food")
oKB.KnowRelation("margherita", "contains", "tomato")
? @@( oKB.Query([ "?x", "is-a", "dish" ]) )
#--> [ "margherita", "tiramisu", "pizza" ]
? @@( oKB.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato" ]
```

## 2. الاستعلام يجيب مما سُجّل

لم يسجّل أحد أن المارغريتا نوع من الطعام. الاستعلام لا يقول إلا ما كُتب.

```ring
? @@( oKB.Query([ "margherita", "kind-of", "?o" ]) )
#--> [ "pizza" ]
```

## 3. القانون يجعل الاستدلال ممكنًا

`kind-of` تتسلسل: المارغريتا نوع من البيتزا، والبيتزا نوع من الطعام. أعلن العلاقة متعدية، فتتبع `Prove`
السلسلة وتُظهر كل خطوة.

```ring
oKB.ConstrainRelation("kind-of", :Transitive)
aProof = oKB.Prove([ "margherita", "kind-of", "food" ])
? aProof[:verdict]
#--> TRUE
? aProof[:narration]
#--> proved: margherita kind-of pizza kind-of food
```

## 4. العالم ملف تستطيع قراءته

```ring
? oKB.ExportToKnow()
#--> knowledge "menu"
#--> margherita | is-a | dish
#--> margherita | contains | tomato
#--> kind-of | transitive
```

## 5. العالم الذي يجري عليه هذا الدرس

فصول هذا الدرس تستدل على ملف عالم. ها هو، مسؤولًا. ما يُطبع يتوقف على العالم، فشغّل الخلية.

```ring
? EduWorldName()
? @@( EduWorld().Query([ "?o", "requested", "?d" ]) )
```

{{exercise:ex-12-01}}

{{exercise:ex-12-02}}

## الخلاصة

- **ما أنجزته:** صرّحت بحقائق في ثلاث كلمات كل واحدة، واستعلمت عنها، وأعلنت علاقة متعدية، وجعلت سوفتانزا
  تثبت سلسلة وتسرد كل خطوة؛ ثم رأيت العالم على أنه الملف البسيط الذي هو.
- **لماذا يهم:** لا تعرف سوفتانزا حقائق العالم. تعرف عالمك *أنت*، وما علّمته إياه فقط، ولذلك يمكن ردّ
  أجوبتها إلى سطر كتبته.
- **ما التالي:** حين تكون في العالم فجوة، تسألك سوفتانزا عنها.
