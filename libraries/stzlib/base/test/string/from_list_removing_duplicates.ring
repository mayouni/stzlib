# Narrative
# --------
# #narration REMOVING DUPLICATES
#
# Extracted from stzlisttest.ring, block #366.
#ERR Error (R14) : Calling Method without definition: linesq

load "../../stzBase.ring"


pr()

# Today, my wife, who manages a singing club, sent me a lengthy
# Arabic song text and asked me to format it into a polished
# Word document for printing.

# While the song itself isn't particularly long, it includes
# many repetitive phrases, and she wanted to remove those duplicates.

# Here is the original full text I put in a stzString object:

o1 = new stzString("خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
آش يهم، آش يهم، آش يهم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
آش يهم، آش يهم، آش يهم
قالوا فينا كلام كثيـر
ما تسمعشي كلام الغيـر
قالوا فينا كلام كثيـر
ما تسمعشي كلام الغيـر
لا يخلوا واحد في خير
ولا يخلوا فرحة تنتم
لا يخلوا واحد في خير
ولا يخلوا فرحة تنتم
آش يهم، آش يهم، آش يهم آش يهم
حسدونا والله الحساد
ما تسلم منهم العباد
حسدونا والله الحساد
ما تسلم منهم العباد
إذا تلموا في ميــعاد
تكثر النكــايد والهم
إذا تلموا في ميــعاد
تكثر النكــايد والهم
آش يهم، آش يهم، آش يهم آش يهم
ما دمنا إحنا الإثنيـن
في جنة عليها راضين
ما دمنا إحنا الإثنيـن
في جنة عليها راضين
آش يهمك من الاخرين
اللي مدحك واللي شتم
آش يهمك من الاخرين
اللي مدحك واللي شتم
آش يهم، آش يهم، آش يهم آش يهم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
خلي يقولوا آش يهم
من اللي يشكر ولا يذم
آش يهم، آش يهم، آش يهم
آش يهم، آش يهم، آش يهم
آش يهم، آش يهم، آش يهم آش يهم" )

# Then I used Softanza to extract the text into individual
# lines and then remove any duplicates.

# As quick as this:

? o1.LinesQ().RemoveDuplicatesQ().Content()
#-->
# 
#o خلي يقولوا آش يهم
#oمن اللي يشكر ولا يذم
#oآش يهم، آش يهم، آش يهم
#oقالوا فينا كلام كثيـر
#oما تسمعشي كلام الغيـر
#oلا يخلوا واحد في خير
#oولا يخلوا فرحة تنتم
#oآش يهم، آش يهم، آش يهم آش يهم
#oحسدونا والله الحساد
#oما تسلم منهم العباد
#oإذا تلموا في ميــعاد
#oتكثر النكــايد والهم
#oما دمنا إحنا الإثنيـن
#oفي جنة عليها راضين
#oآش يهمك من الاخرين


pf()
# Executed in 0.01 second(s) in Ring 1.22
