# وكيل لا يستطيع أن يؤذي

*مدخل أساسي · الفصل 14 · المهارات GO-01 «ماذا يغطي وكيلي، وما الذي يمكن التراجع عنه؟» وGO-02 «من المسموح له أن يجعل هذا حقيقيًا؟» وGO-03 «ماذا كان سيفعل؟»*

> ترجمة أولية، في انتظار مراجعة متحدث أصلي.

الوكيل برنامج يتصرّف من تلقاء نفسه. تتيح لك سوفتانزا أن تبني واحدًا بأمان، لأن الأمان ليس في الوكيل: بل في
العالم من حوله. محكمة تحكم على التصريح، وبوابة تقف بين كل اقتراح وكل أثر، وغرفة تدريب تتلقى الفعل قبل
الواقع.

## 1. صرّح بوكيل، ودع المحكمة تحكم عليه

الوكيل ملف نصي. عليه أن يقول ما يغطيه وأيّ صنف من الأفعال يقوم به، وإلا فلن يُجدول أبدًا.

```ring
cPia = "pia: 1
name: stock-watcher
kind: pi
coverage: checks the kitchen stock every morning and notes what is low
reversibility: reversible
schedule:
  timer: 20
memory:
  - stock level unknown
skills:
  - name: check-stock
    when: always
    does: learn stock level checked
    verify: fact stock level checked
"
oDecl = StzAgentDeclarationQ(cPia)
? oDecl.IsValid()
#--> TRUE
? oDecl.ReversibilityClass()
#--> reversible
```

## 2. ترفض المحكمة ما لا يقول شيئًا عن مداه

```ring
oBad = StzAgentDeclarationQ( StzReplace(cPia, "coverage: checks the kitchen stock every morning and notes what is low" + char(10), "") )
? oBad.IsValid()
#--> FALSE
? StzLeft( oBad.CiteFindings(), 25 )
#--> [pia-coverage @ coverage]
```

## 3. اقترح ولا تنفّذ: شكل النظام الآمن

يجوز لنموذج لغوي أن يقترح. صِله مباشرة بأثر، فيصير رسم النظام غير سليم؛ والمخالفة تقول لماذا.

```ring
oGBad = new stzAgentGraph("mailer-bad")
oGBad.AddLLMActor("writer")
oGBad.AddEffect("send")
oGBad.Proposes("writer", "send")
? oGBad.IsSound()
#--> FALSE
? oGBad.Violations()[1][:message]
#--> effect 'send' has no guardian edge into it -- every effect passes a pi-gate
```

## 4. الشكل المحكوم

بوابة بين الاقتراح والأثر، وأثر متتبَّع بعده.

```ring
oGOk = new stzAgentGraph("mailer")
oGOk.AddLLMActor("writer")
oGOk.AddGuardian("gate")
oGOk.AddEffect("send")
oGOk.AddTraceSink("audit")
oGOk.Proposes("writer", "gate")
oGOk.Guards("gate", "send")
oGOk.Feeds("gate", "send")
oGOk.Traces("send", "audit")
? oGOk.IsSound()
#--> TRUE
```

## 5. تدرّب في عالم آمن

أعطِ الوكيل ورشة، فيحطّ كل ما يكتبه فيها. القرص لا يتحرك؛ والشيء الوحيد الذي يخرج هو خطة.

```ring
oAg = oDecl.ToAgent()
oAg.GiveWorkbench()
cHere = StzReplace(currentdir(), char(92), "/")
cNote = cHere + "/t_edu_note_" + ProcessId() + ".txt"
oAg.WorkbenchQ().WriteFile(cNote, "stock is low")
? fexists(cNote)
#--> FALSE
? oAg.WorkbenchQ().ContentOf(cNote)
#--> stock is low
oPlan = oAg.GenerateUpdatePlan()
? oPlan.NumberOfOperations()
#--> 1
```

## 6. لا يستطيع ذكاء اصطناعي أن ينفّذ الخطة

```ring
oPlan.SetExecutor( LLMActor("helper") )
aMay = oPlan.MayCommit()
? aMay[1]
#--> FALSE
? aMay[2]
#--> actor 'helper' cannot commit -- it lacks the 'effectful' capability (required by operation 1)
```

## 7. لا يغيّر الواقع إلا ممثل تنفيذ، داخل نطاقه

المقترح مبدع. والمنفّذ حتمي، يملك الصلاحية، ويجوز له أن يمسّ مجلدًا واحدًا لا غير. الآن، والآن فقط، يوجد
الملف.

```ring
oPlan2 = oAg.GenerateUpdatePlan()
oPlan2.SetExecutor( PIActor("committer") )
oScope = new stzCommitScope()
oScope.AllowUnder(cHere)
oPlan2.SetScope(oScope)
aRes = oPlan2.Execute()
? aRes[1][2]
#--> TRUE
? fexists(cNote)
#--> TRUE
remove(cNote)
```

{{exercise:ex-14-01}}

{{exercise:ex-14-02}}

{{exercise:ex-14-03}}

## الخلاصة

- **ما أنجزته:** صرّحت بوكيل فقبلته المحكمة ورفضت توأمه المهمل، ووصلت اقتراحًا عبر بوابة ورأيت الشكل غير
  السليم مسمّى، وتدرّبت على فعل لم يمسّ القرص قط ولم يستطع ذكاء اصطناعي تنفيذه.
- **لماذا يهم:** يستطيع الطالب أن يبني وكيلًا لأن الوكيل لا يستطيع أن يؤذي. الأمان في المحكمة والبوابة
  وغرفة التدريب، لا في حسن نوايا الطالب.
- **ما التالي:** الأدوات التي فحصت كل فصل من هذا الدرس، بين يديك.
