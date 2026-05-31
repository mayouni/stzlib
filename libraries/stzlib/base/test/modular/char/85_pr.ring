# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #85.

load "../../../stzBase.ring"


? Languages()
#--> 	c, :abkhazian, :oromo, :afar, :afrikaans, :albanian, :amharic,
#	:arabic, :armenian, :assamese, :aymara, :azerbaijani, :bashkir,
#	:basque, :bengali, :dzongkha, :bislama, :breton, :bulgarian,
#	:burmese, :belarusian, :khmer, :catalan, :chinese, :corsican,
#	:croatian, :czech, :danish, :dutch, :english, :esperanto, :estonian,
#	:faroese, :fijian, :finnish, :french, :western_frisian, :gaelic,
#	:galician, :georgian, :german, :greek, :greenlandic, :guarani,
#	:gujarati, :hausa, :hebrew, :hindi, :hungarian, :icelandic,
#	:indonesian, :interlingua, :interlingue, :inuktitut, :inupiak,
#	:irish, :italian, :japanese, :javanese, :kannada, :kashmiri,
#	:kazakh, :kinyarwanda, :kirghiz, :korean, :kurdish, :rundi,
#	:lao, :latin, :latvian, :lingala, :lithuanian, :macedonian,
#	:malagasy, :malay, :malayalam, :maltese, :maori, :marathi,
#	:marshallese, :mongolian, :nauruan, :nepali, :norwegian_bokmal,
#	:occitan, :oriya, :pashto, :persian, :polish, :portuguese, :punjabi,
#	:quechua, :romansh, :romanian, :russian, :samoan, :sango, :sanskrit,
#	:serbian, :ossetic, :southern_sotho, :tswana, :shona, :sindhi, :sinhala,
#	:swati, :slovak, :slovenian, :somali, :spanish, :sundanese, :swahili,
#	:swedish, :sardinian, :tajik, :tamil, :tatar, :telugu, :thai, :tibetan,
#	:tigrinya, :tongan, :tsonga, :turkish, :turkmen, :tahitian, :uighur,
#	:ukrainian, :urdu, :uzbek, :vietnamese, :volapuk, :welsh, :wolof,
#	:xhosa, :yiddish, :yoruba, :zhuang, :zulu, :norwegian_nynorsk, :bosnian,
#	:divehi, :manx, :cornish, :akan, :konkani, :ga, :igbo, :kamba, :syriac,
#	:blin, :geez, :koro, :sidamo, :atsam, :tigre, :jju, :friulian, :venda,
#	:ewe, :walamo, :hawaiian, :tyap, :nyanja, :filipino, :swiss_german,
#	:sichuan_yi, :kpelle, :low_german, :south_ndebele, :northern_sotho,
#	:northern_sami, :taroko, :gusii, :taita, :fulah, :kikuyu, :samburu,
#	:sena, :north_ndebele, :rombo, :tachelhit, :kabyle, :nyankole, :bena,
#	:vunjo, :bambara, :embu, :cherokee, :mauritian, :makonde, :langi, :ganda,
#	:bemba, :kabuverdianu, :meru, :kalenjin, :nama, :machame, :colognian,
#	:masai, :soga, :luyia, :asu, :teso, :saho, :koyra_chiini, :rwa, :luo,
#	:chiga, :standard_morocco_tamazight, :koyraboro_senni, :shambala, :bodo,
#	:avaric, :chamorro, :chechen, :church, :chuvash, :cree, :haitian, :herero,
#	:hiri_motu, :kanuri, :komi, :kongo, :kwanyama, :limburgish, :luba_katanga,
#	:luxembourgish, :navaho, :ndonga, :ojibwa, :pali, :walloon, :aghem, :basaa,
#	:zarma, :duala, :jola_fonyi, :ewondo, :bafia, :makhuwa_meetto, :mundang,
#	:kwasio, :coptic, :sakha, :sangu, :tasawaq, :vai, :walser, :yangben,
#	:avestan, :ngomba, :kako, :meta, :ngiemboon, :aragonese, :akkadian,
#	:ancient_egyptian, :ancient_greek, :aramaic, :balinese, :bamun, :batak_toba,
#	:buginese, :chakma, :dogri, :gothic, :ingush, :mandingo, :manipuri, :old_irish,
#	:old_norse, :old_persian, :pahlavi, :phoenician, :santali, :saurashtra,
#	:tai_dam, :tai_nua, :ugaritic, :akoose, :lakota, :standard_moroccan_tamazight,
#	:mapuche, :central_kurdish, :lower_sorbian, :upper_sorbian, :kenyang, :mohawk,
#	:nko, :prussian, :kiche, :southern_sami, :lule_sami, :inari_sami, :skolt_sami,
#	:warlpiri, :mende, :maithili, :american_sign_language, :bhojpuri,
#	:literary_chinese, :mazanderani, :newari, :northern_luri, :palauan,
#	:papiamento, :tokelauan, :tok_pisin, :tuvaluan, :cantonese, :osage, :ido,
#	:lojban, :sicilian, :southern_kurdish, :western_balochi, :cebuano, :erzya,
#	:chickasaw, :muscogee, :silesian

pf()
# Executed in almost 0 second(s) in Ring 1.23
