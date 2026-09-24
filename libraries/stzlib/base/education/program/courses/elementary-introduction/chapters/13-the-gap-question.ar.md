# سؤال الفجوة

*مدخل أساسي · الفصل 13 · المهارتان KN-03 «ماذا سألتني سوفتانزا، ولماذا؟» وKN-04 «بماذا تسمّي المكتبة الشيء الذي أقصده؟»*

> ترجمة أولية، في انتظار مراجعة متحدث أصلي.

الطلب الغامض يلقى تخمينًا من معظم الأنظمة. أما سوفتانزا فتسأل. أنت تعلن ما يجب أن يحتويه عالم مكتمل،
فتصير الفجوة بين ذلك الهدف والعالم هي السؤال التالي، مع سببه. ويوجّه هذا الفصل الفكرة نفسها إلى المكتبة
ذاتها: تسألها بماذا تسمّي الشيء الذي تقصده.

## 1. أعلن هدفًا

على كل طبق أن يقول ما يحتويه. طبقان، ولا شيء مسجّل: فجوتان.

```ring
oRest = new stzKnowledgeGraph("restaurant")
oRest.Know("margherita", "dish").Know("tiramisu", "dish")
oRest.AddConversationQ("setup").SetGoal(StzGoalQ().RequireEach("dish", "contains"))
? len( oRest.GapsIn("setup") )
#--> 2
```

## 2. تسأل سوفتانزا، وتقول لماذا

```ring
aQ = oRest.AskInXT("setup")
? aQ[:question]
#--> What does 'margherita' have for 'contains'?  (why: every dish needs 'contains')
```

## 3. تجيب بالكلمات، فينمو العالم

```ring
aV = oRest.ReplyIn("setup", "tomato and mozzarella")
? @@( aV[:admitted] )
#--> [ "tomato", "mozzarella" ]
? @@( oRest.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato", "mozzarella" ]
? len( oRest.GapsIn("setup") )
#--> 1
```

## 4. السؤال التالي يعرض ما يعرفه من قبلُ

```ring
aQ2 = oRest.AskInXT("setup")
? aQ2[:question]
#--> Which 'contains' does 'tiramisu' have? (1) tomato  (2) mozzarella -- or answer freely.  (why: every dish needs 'contains')
```

## 5. اسأل المكتبة بماذا تسمّي ما تقصده

المكتبة تصف نفسها. `HowTo` تحوّل القصد إلى نداء، وتقول كيف وصلت إليه.

```ring
oDoc = StzSelfDocQ("stzList")
? oDoc.HowTo("remove duplicates")
#--> Q([...]).RemoveDuplicates()   -- composed by grammar (remove duplicates)
? oDoc.HasMethod("DuplicatesRemoved")
#--> TRUE
```

## 6. اشرح دالة، وارفض دالة مجهولة

```ring
? StzLeft( oDoc.ExplainMethod("DuplicatesRemoved"), 20 )
#--> DuplicatesRemoved --
? oDoc.ExplainMethod("NoSuchThing")
#--> No method 'NoSuchThing' in stzList.
```

{{exercise:ex-13-01}}

{{exercise:ex-13-02}}

## الخلاصة

- **ما أنجزته:** أعلنت هدفًا، وتلقيت سؤال الفجوة مع سببه، وأجبت بالكلمات، ورأيت السؤال التالي يعرض ما كان
  معروفًا، وطلبت من المكتبة أن تسمّي دالة من قصدك.
- **لماذا يهم:** النظام الذي يسأل يعلّمك ما يحتاجه النموذج المكتمل. والنظام الذي يخمّن يخفيه عنك.
- **ما التالي:** وكيل يقترح ولا يستطيع أن يفعل.
