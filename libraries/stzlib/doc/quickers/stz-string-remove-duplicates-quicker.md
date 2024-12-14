# Removing Duplicates in Softanza: Meet RemoveDuplicates()

Today, my wife, who manages a singing club, sent me a lengthy classic tunsian song text, written in arabic, and asked me to format it into a polished Word document for printing.

While the song itself isn't particularly long, it includes many repetitive phrases, and she wanted to remove those duplicates.

Here is the original full text I put in a `stzString` object:

```ring
load "stzlib.ring"

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
```

I instructed Softanza to extract the text into individual **lines** and then **remove** any duplicates:

```ring
? o1.LinesQ().RemoveDuplicatesQ().Content()
#-->
# خلي يقولوا آش يهم
# من اللي يشكر ولا يذم
# آش يهم، آش يهم، آش يهم
# قالوا فينا كلام كثيـر
# ما تسمعشي كلام الغيـر
# لا يخلوا واحد في خير
# ولا يخلوا فرحة تنتم
# آش يهم، آش يهم، آش يهم آش يهم
# حسدونا والله الحساد
# ما تسلم منهم العباد
# إذا تلموا في ميــعاد
# تكثر النكــايد والهم
# ما دمنا إحنا الإثنيـن
# في جنة عليها راضين
# آش يهمك من الاخرين
```

As quick as this!

>**NOTE**: Softanza offers a variety of functions for managing duplicates, all of which work seamlessly with both strings and lists.