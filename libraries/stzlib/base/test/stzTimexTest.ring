load "../stzbase.ring"

/*---
*/
pr()

# Match business hours (9 AM - 5 PM, 12h format)
oTx = Tx("[@H12(9..12), @P{AM}, @H12(1..5), @P{PM}]")
? oTx.Match([9, "AM", 2, "PM"])  #--> TRUE

# Match exact time components
oTx = Tx("[@H{9;14;18}, @M{0;30}, @S?]")
? oTx.Match([14, 30, 0])  #--> TRUE (2:30:00 PM)

# Validate meeting times (hour + minute, second optional)
oTx = Tx("[@H, @M, @S?]")
? oTx.Match([10, 30])      #--> TRUE
? oTx.Match([10, 30, 45])  #--> TRUE

# Negation - exclude lunch hour
oTx = Tx("[@!H{12}, @M]")
? oTx.Match([12, 0])  #--> FALSE
? oTx.Match([13, 0])  #--> TRUE

pf()

/*--- ADVANCED PATTERS

# Recurring meeting pattern (every 15 minutes)
oTx = Tx("[@H(9..17), @M{0;15;30;45}]")

# High-precision logging (with milliseconds)
oTx = Tx("[@H, @M, @S, @MS(0..100)]")

# Flexible schedule (2-4 time slots)
oTx = Tx("[@H, @M]2-4")
? oTx.Match([9,0, 12,0, 15,0])  #--> TRUE (3 slots)


/*--- INTEGRATION WITH SOFTANZA TEMPORAL CLASSES

# From stzTime
oTime = TimeQ("14:30:45")
aComponents = [oTime.Hours(), oTime.Minutes(), oTime.Seconds()]

oTx = Tx("[@H(9..17), @M, @S]")
? oTx.Match(aComponents)  #--> TRUE

# Validate time ranges in stzTimeline
oTx = Tx("[@H12(8..12), @P{AM;PM}]")
# Use for validating business hour events
