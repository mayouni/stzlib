# goldens_v1.ring -- the :ocr faculty golden set, version v1: one item per key sentence of a golden document, the
# document given as its rendered pages (150 dpi, greyscale, in this folder) and the language pack to use.
# Generated from the document goldens (an independent author never saw a reader) -- the expected.json of
# golden_v36/z09 (French) and golden_v35/y11 (Arabic); do not edit by hand: re-generate from those files.

func StzOcrGoldensV1(pcDir)
	_a_ = []
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "La ligne 12 relie la gare routière à l'hôpital Saint-Lazare en vingt-quatre minutes." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Elle circule toute l'année du lundi au samedi, de 6h40 à 20h15." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Les tickets s'achètent auprès du conducteur ou aux distributeurs de la gare routière." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Les enfants de moins de quatre ans voyagent gratuitement." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Tous les bus de la ligne 12 sont équipés d'une rampe d'accès et d'annonces sonores et visuelles." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Le conducteur peut déployer la rampe sur simple demande." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Les objets oubliés dans un bus sont déposés à l'agence de la gare routière sous vingt-quatre heures." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "Ils sont conservés pendant trois mois." ])
	add(_a_, [ [ :pages = [ pcDir + "z09_p1_150dpi.png", pcDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ], "L'agence est ouverte du lundi au vendredi de 8h00 à 17h30." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "يوضح هذا الملخص أهم شروط وثيقة تأمين المنزل الصادرة عن شركة الأمان الوطنية للتأمين." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "ولا يغني هذا الملخص عن قراءة الوثيقة الكاملة، وعند الاختلاف يؤخذ بنص الوثيقة." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "تغطى المقتنيات الثمينة، مثل المجوهرات واللوحات، حتى مبلغ 20,000 ريال فقط ما لم تُذكر في ملحق خاص." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "يمكن دفع القسط السنوي دفعة واحدة أو على قسطين متساويين." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "تجدد الوثيقة تلقائيًا في نهاية المدة ما لم يخطر أحد الطرفين الآخر كتابةً قبل ثلاثين يومًا." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "يحق للمؤمَّن له إلغاء الوثيقة في أي وقت، ويُردّ إليه جزء من القسط عن المدة المتبقية." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "اتصل بمركز الخدمة على مدار الساعة." ])
	add(_a_, [ [ :pages = [ pcDir + "y11_p1_150dpi.png", pcDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ], "صورة من الوثيقة وبطاقة الهوية." ])
	return _a_
