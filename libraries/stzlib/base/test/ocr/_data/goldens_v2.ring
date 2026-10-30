# goldens_v2.ring -- the :ocr faculty golden set, version v2: one item per key sentence of a golden document, the
# document given as its rendered pages (150 dpi, greyscale, in this folder) and the language pack to use. v2 = v1
# (golden_v36/z09 French, golden_v35/y11 Arabic) + golden_v33/u06 Russian: the faculty is measured PER LANGUAGE
# from v2 on (ruled by the author 2026-10-30, OCR-PERLANG-01), so each language needs items of its own.
# Generated from the documents' expected.json, whose authors never saw a reader; do not edit by hand.

func StzOcrGoldensV2(pcDir)
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
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Шлюз телеметрии ТМ-200 предназначен для сбора данных с датчиков и передачи их на сервер по защищённому каналу." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Настоящее руководство описывает подключение устройства и настройку его параметров." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Для подключения устройства выполните следующие действия." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Параметры хранятся в текстовом файле config.ini. Пример файла приведён ниже." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Допустимые значения параметров приведены в таблице 1." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Состояние устройства определяется по индикатору на передней панели." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Изготовитель гарантирует соответствие шлюза техническим характеристикам в течение 24 месяцев со дня продажи." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Гарантия не распространяется на устройства, имеющие механические повреждения или следы вскрытия корпуса." ])
	add(_a_, [ [ :pages = [ pcDir + "u06_p1_150dpi.png", pcDir + "u06_p2_150dpi.png", pcDir + "u06_p3_150dpi.png" ], :lang = "ru-RU" ], "Служба технической поддержки работает по рабочим дням с 9:00 до 18:00." ])
	return _a_
