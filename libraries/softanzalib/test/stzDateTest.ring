load "stzlib.ring"

# TODO fix errors

d1 = new stzDate([ :Year = 2020, :Day = "12", :Month = "12"  ])
d2 = new stzDate("10/12/2020")
d3 = new stzDate(10122020)

? d1 + "28 days"
? d2 + "11 months"
? d3 + "3 years"
