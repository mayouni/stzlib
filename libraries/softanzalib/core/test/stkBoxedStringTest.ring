load "../string/stkBoxedString.ring"

decimals(3)
t0 = clock()

#~~~~~~

? BoxedString("Hello, Ring!")
#-->
'
╭──────────────╮
│ Hello, Ring! │
╰──────────────╯
'

? BoxedString("Hello, World!") 
#-->
'
╭───────────────╮
│ Hello, World! │
╰───────────────╯
'

? BoxedString("This is a
multi-line
string example.")
#-->
'
╭─────────────────╮
│ This is a       │
│ multi-line      │
│ string example. │
╰─────────────────╯
'

? BoxedChars("RING")
#-->
'
╭───┬───┬───┬───╮
│ R │ I │ N │ G │
╰───┴───┴───┴───╯
'

? BoxedString("")
#-->
'
╭──╮
╰──╯
'

? BoxedChars("")
#-->
'
╭──╮
╰──╯
'

# Executed in 0.001 seconds.

#~~~~~~

? NL + "~~~~~~~"

t = (clock() - t0) / clockspersecond()
? "Executed in " + t + " seconds."
