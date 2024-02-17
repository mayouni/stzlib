
# A random 100 words in english, french and arabic

_a100Words = [ 
  [ "apple", "pomme", "تفاحة" ], 
  [ "book", "livre", "كتاب" ], 
  [ "chair", "chaise", "كرسيّ" ], 
  [ "dog", "chien", "كلب" ], 
  [ "elephant", "éléphant", "فيل" ], 
  [ "flower", "fleur", "زهرة" ], 
  [ "glass", "verre", "زجاجة" ], 
  [ "hat", "chapeau", "قبعة" ], 
  [ "ink", "encre", "حبر" ], 
  [ "juice", "jus", "عصير" ], 
  [ "key", "clé", "مفتاح" ], 
  [ "lamp", "lampe", "مصباح" ], 
  [ "map", "carte", "خريطة" ], 
  [ "notebook", "cahier", "دفتر" ], 
  [ "orange", "orange", "برتقال" ], 
  [ "pen", "stylo", "قلم" ], 
  [ "queen", "reine", "ملكة" ], 
  [ "rain", "pluie", "مطر" ], 
  [ "sun", "soleil", "شمس" ], 
  [ "table", "table", "طاولة" ], 
  [ "umbrella", "parapluie", "مظلة" ], 
  [ "vase", "vase", "مزهرية" ], 
  [ "water", "eau", "ماء" ], 
  [ "xylophone", "xylophone", "زيلوفون" ], 
  [ "yacht", "yacht", "يخت" ], 
  [ "wind", "vent", "ريح" ], 
  [ "banana", "banane", "موز" ], 
  [ "cat", "chat", "قطة" ], 
  [ "door", "porte", "باب" ], 
  [ "egg", "œuf", "بيضة" ], 
  [ "fish", "poisson", "سمك" ], 
  [ "guitar", "guitare", "قيثارة" ], 
  [ "horse", "cheval", "حصان" ], 
  [ "ice", "glace", "ثلج" ], 
  [ "point", "point", "نقطة" ], 
  [ "window", "fenêtre", "نافذة" ], 
  [ "lemon", "citron", "ليمون" ], 
  [ "moon", "lune", "قمر" ], 
  [ "nest", "nid", "عش" ], 
  [ "ball", "balle", "كرة" ], 
  [ "text", "texte", "نصّ" ], 
  [ "question", "question", "سؤال" ], 
  [ "rose", "rose", "وردة" ], 
  [ "computer", "ordinateur", "حاسوب" ], 
  [ "tree", "arbre", "شجرة" ], 
  [ "umbrella", "parapluie", "مظلة" ], 
  [ "bag", "sac", "كيس" ], 
  [ "watermelon", "pastèque", "بطيخ" ], 
  [ "job", "travail", "مهنة" ], 
  [ "milk", "lait", "حليب" ], 
  [ "music", "musique", "موسيقى" ], 
  [ "airplane", "avion", "طائرة" ], 
  [ "bicycle", "vélo", "دراجة" ], 
  [ "car", "voiture", "سيارة" ], 
  [ "train", "train", "قطار" ], 
  [ "bus", "bus", "حافلة" ], 
  [ "pupil", "élève", "تلميذ" ], 
  [ "truck", "camion", "شاحنة" ], 
  [ "boat", "bateau", "قارب" ], 
  [ "ship", "navire", "سفينة" ], 
  [ "helicopter", "hélicoptère", "مروحيّة" ], 
  [ "rocket", "fusée", "صاروخ" ], 
  [ "submarine", "sous-marin", "غوّاصة" ], 
  [ "tractor", "tracteur", "جرّار" ], 
  [ "one", "un", "واحد" ], 
  [ "two", "deux", "اثنان" ], 
  [ "three", "trois", "ثلاثة" ], 
  [ "four", "quatre", "سيارة إطفاء" ], 
  [ "five", "cinq", "سيارة شرطة" ], 
  [ "station", "station", "محطّة" ], 
  [ "airport", "aéroport", "مطار" ], 
  [ "six", "six", "ستّة" ], 
  [ "seven", "sept", "سبعة" ], 
  [ "eight", "huit", "ثمانية" ], 
  [ "nine", "neuf", "تسعة" ], 
  [ "bridge", "pont", "جسر" ], 
  [ "tunnel", "tunnel", "نفق" ], 
  [ "road", "route", "طريق" ], 
  [ "street", "rue", "نهج" ], 
  [ "ten", "dix", "عشرة" ], 
  [ "avenue", "avenue", "شارع" ], 
  [ "square", "carré", "ساحة" ], 
  [ "word", "mot", "كلمة" ], 
  [ "garden", "jardin", "حديقة" ], 
  [ "forest", "forêt", "غابة" ], 
  [ "base", "base", "قاعدة" ], 
  [ "desert", "désert", "صحراء" ], 
  [ "mountain", "montagne", "جبل" ], 
  [ "hill", "colline", "تلّ" ], 
  [ "valley", "vallée", "وادي" ], 
  [ "ocean", "océan", "محيط" ], 
  [ "sea", "mer", "بحر" ], 
  [ "lake", "lac", "بحيرة" ], 
  [ "river", "rivière", "نهر" ], 
  [ "stream", "ruisseau", "جدول" ], 
  [ "pond", "étang", "بركة" ], 
  [ "island", "île", "جزيرة" ], 
  [ "beach", "plage", "شاطئ" ], 
  [ "sand", "sable", "رمل" ], 
  [ "wave", "vague", "موج" ], 
  [ "sound", "son", "صوت" ], 
  [ "book", "livre", "كتاب" ]
]


func 100WordsXT()
	return _a100Words

func 100Words()
	return 100EnglishWords()

	func Words()
		return 100EnglishWords()

func 100EnglishWords()
	acResult = []
	nLen = len(_a100Words)

	for i = 1 to nLen
		acResult + _a100Words[i][1]
	next

	return acResult

	func EnglishWords()
		return 100EnglishWords()

func 100FenshWords()
	acResult = []
	nLen = len(_a100Words)

	for i = 1 to nLen
		acResult + _a100Words[i][2]
	next

	return acResult

	func FrenshWords()
		return 100FrenshhWords()

func 100ArabicWords()
	acResult = []
	nLen = len(_a100Words)

	for i = 1 to nLen
		acResult + _a100Words[i][3]
	next

	return acResult

	func ArabicWords()
		return 100ArabicWords()
