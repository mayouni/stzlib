# goldens_ru_u06.ring -- Russian key sentences for measuring the :ocr model's Cyrillic recogniser (OCR slice O3c),
# one item per key sentence of golden_v33/u06 (a Russian technical manual, 3 pages rendered at 150 dpi, greyscale, in this
# folder), in the same [ input, sentence ] shape as goldens_v1.ring. Generated from u06.expected.json, whose author never
# saw a reader; do not edit by hand. NOT the faculty's golden set: the registry measures goldens v1 -- whether :ocr is
# measured per language is an open question for the author (OCR-PERLANG-01), and this set is its first Cyrillic evidence.

func StzOcrGoldensRuU06(pcDir)
	_a_ = []
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
