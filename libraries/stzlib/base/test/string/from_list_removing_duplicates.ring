load "../../stzBase.ring"
load "../_narrated.ring"

# A repetitive Arabic song, split into lines and de-duplicated in one
# chain -- sixteen distinct lines survive, in first-appearance order.
# Extracted from stzlisttest.ring, block #366.

Scenario("Removing duplicate lines of a song")
	o1 = new stzString("خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
آش يهم، آش يهم، آش يهم
قالوا فينا كلام كثيـر
ما تسمعشي كلام الغيـر
قالوا فينا كلام كثيـر
لا يخلوا واحد في خير
ولا يخلوا فرحة تنتم
آش يهم، آش يهم، آش يهم آش يهم
حسدونا والله الحساد
ما تسلم منهم العباد
إذا تلموا في ميــعاد
تكثر النكــايد والهم
ما دمنا إحنا الإثنيـن
في جنة عليها راضين
آش يهمك من الاخرين
خلي يقولوا آش يهم")
	aAll = o1.LinesQ().Content()
	aUniq = o1.LinesQ().RemoveDuplicatesQ().Content()
	Then("nineteen lines in, fifteen out", len(aAll), 19)
	Then("the first line survives", aUniq[1], "خلي يقولوا آش يهم")
	Then("duplicates were dropped", len(aUniq), 15)
EndScenario()

Scenario("... and the survivors are genuinely distinct")
	o2 = new stzString("a
b
a
c
b")
	Then("five in, three out",
		ListEq( o2.LinesQ().RemoveDuplicatesQ().Content(), [ "a", "b", "c" ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
