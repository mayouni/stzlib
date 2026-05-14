load "../stzbase.ring"

pr()

# --- _FindSubStr via engine ---

o1 = new stzString("Hello World Hello")

? o1.FindFirst("Hello")
#--> 1

? o1.FindLast("Hello")
#--> 13

? o1.NumberOfOccurrence("Hello")
#--> 2

# Case-insensitive
? o1.FindFirstCS("hello", FALSE)
#--> 1

# --- _ReplaceRange via engine ---

o2 = new stzString("ABCDEF")
o2.ReplaceSection(2, 4, "xyz")
? o2.Content()
#--> AxyzEF

# --- _SplitByStr via engine ---

o3 = new stzString("one:two:three")
? @@( o3.Split(":") )
#--> [ "one", "two", "three" ]

# --- Basic content ---

o4 = new stzString("cafe")
? o4.Content()
#--> cafe

? len(o4.Content())
#--> 4

pf()
