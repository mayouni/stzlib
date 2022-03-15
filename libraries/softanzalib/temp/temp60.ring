load "stzlib.ring"

// Getting the first day of week in the french locale
o1 = new stzLocale("fr_FR")
? o1.Country()
? o1.FirstDayOfWeek()
? ""
// Getting the first day of week in the egyptian locale
o1 = new stzLocale("ar_EG")
? o1.Country()
? o1.FirstDayOfWeek()





