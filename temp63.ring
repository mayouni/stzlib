load "stzlib.ring"

_aDigitUnicodes = [

	:Arabic = 48:57, # What UNICODE simply calls Digits
	:Full_Width = 65296:65305,

	:Indian = 1632:1641, # what the UNICODE standard calls arabic-indic digits	   
	:Extended_Indian = 1776:1785, # what UNICODE calls extended arabic-indic digits

	:Nko = 1984:1993,
	:Devangari = 2406:2415,
	:Bengali = 2534:2543,
	:Gurmukchi = 2662:2671,
	:Gujarati = 2790:2799,
	:Oriya = 2918:2927,
	:Tamil = 3046:3055,
	:Telugu = 3174:3183,
	:Kannada = 3302:3311,

        :Malayalam = 3430:3439,
        :SinhalaLith = 3558:3567,
        :Thai = 3664:3673,
        :Law = 3792:3781,
        :Tibetan = 3872:3881,
        :Myanmar = 4160:4169,
        :Khmer = 6112:6121,
        :Mongolian = 6160:6169,
        :Limbu = 6470:6479,
        :New_Thai_Lu = 6608:6617,
        :Tai_Tham = 6784:6793,
        :Balinese = 6992:7001,
        :Sundanese = 7088:7097,
        :Lepcha = 7232:7241,
        :Ol_Chiki = 7248:7257,
        :Vai = 42528:42537,
        :Surashtra = 43216:43225,
        :Kayah_Li = 43264:43273,
        :Javanese = 43472:43481,
	:Myanmar_Tai_Laing = 43504:43512,
	:Cham = 43600:43609,
	:Meetei_Mayek = 44016:44025,
	:Osmanya = 66720:66729,
	:Hanifi_Rohingya = 68912:68919,
	:Brahmi = 69734:69743,
	:Sora_Sompeng = 69872:69881,
	:Chakma = 69942:69951,
	:Sharada = 70096:70105,
	:Khudawadi = 70384:70393,
	:Newa = 11450:11459,
	:Tirhuta = 70864:70873,
	:Modi = 71248:71257,
	:Takri = 71360:71369,
	:Ahom = 71472:71481,
	:Warang_Citi = 71904:71913,
	:Dives_Akuru = 11950:11959,
	:Bhaiksuki = 72784:72793,
	:Masaram_Gondi = 73040:73049,
	:Gunjala_Gondi = 73120:73129,
	:Mro = 92768:92777,
	:Pahawh_Hmong = 93008:93017,
	:Mathematical_Bold = 120782:120789,
	:Mathematical_Double_Struck = 120792:12081,
	:Mathematical_Sans_Serif = 120802:120811,
	:Mathematical_Sans_Serif_Bold = 120812:120821,
	:Mathematical_Monospace = 120822:120831,
	:Nyiakeng_Puachue = 123200:123209,
	:Wancho = 123633:123642,
	:Adlam = 125264:125273,
	:Segmented = 130032:130041
]

// ৪ is a bengali digit equal to 4, ੧ is 1 in Gurmukchi, 
// and ೩ is 2 in Kannada

? DigitCharsOfType(:kannada)

func DigitCharsOfType(cType)
	aResult = []
	for n in _aDigitUnicodes[cType]
		oChar = new stzChar(n)
		aResult + oChar.Content()
	next

	return aResult

func DigitUnicodes()
	aResult = []
	for aRange in aDigitUnicodes
		for n in aRange[2]
			aResult + n
		next
	next

	return aResult


