load "SoftanzaLib.ring"

//d1 = new stzDate("28/12/2012")
d1 = new stzDate("26-12-1738")
//d1 = new stzDate(12122012)

//d1 = new stzDate([ :Day = 12, :Month = 12, :Year = 2020 ])
//? d1 + 52
//? d1 - 13
/*
? d1.days()
? d1.months()
? d1.years()
*/
? d1.stzaddDays(-10000)
