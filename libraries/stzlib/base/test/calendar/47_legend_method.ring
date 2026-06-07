# Narrative
# --------
# #  Legend method                 #
#
# Extracted from stzcalendartest.ring, block #47.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    aLegend = Legend()
    
    ? "Legend entries:"
    ? @@NL(aLegend)
    #--> [
    # 	[ "holiday", "[D]" ],
    # 	[ "weekend", "░" ]
    # ]

    oLegendQ = LegendQ()
    ? nl + "LegendQ returns stzList: " + ring_classname(oLegendQ)
    #--> LegendQ returns stzList: stzlist
}

pf()
# Executed in 0.19 second(s) in Ring 1.24
