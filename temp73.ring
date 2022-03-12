load "stzlib.ring"

/*
_cArabicTamdeed = "ـ"

كماليّــــات
كماليّ_ـــات
? unicode("ّ")

? StzCharQ(1617).IsLetter()

// 1611 to 1631 + 1643:1644 + 1748 to 1773
*/
? unicode("ــ")
? unicode("__ـ")
? unicode("—")


/*
o1 = new stzString("جٌ")
? unicode(o1[2])

? UnicodeToChar(1612)

"ـ"
for i = 1590 to 1610
	? UnicodeToChar(i)
next
/*

#? DecimalToHex("1612")


#? Arabic7araket()



? Unicode("َ")



