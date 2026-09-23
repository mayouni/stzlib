#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTUTOR                    #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The TUTOR asks, and never cheats. It is     #
#                  wise coding pointed at the gap between the  #
#                  learner's attempt and what the exercise     #
#                  needs, under Zai-Jr's three rules.          #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# THE THREE RULES (charter 5.5, adopted from Zin's Zai-Jr design):
#   1. it never writes the learner's code before the exercise is passed;
#   2. it never explains ahead of where the learner is (a spoiler);
#   3. it never answers before the learner has tried.
#
# BY CONSTRUCTION, not by vigilance: every reply is built from the
# templates below, and no template carries code. A last filter removes
# any word a right answer calls (ForbiddenWords) should one ever slip
# into a reply -- and FilteredCount() lets a guard prove it never had to.
#
# THE GAP IS WISE CODING'S, not a keyword guess: the learner's attempt
# becomes facts in a small knowledge space (the attempt ASKS, FINDS,
# APPLIES), the exercise's needed steps become a stzGoal, and the
# conversation's own AskInXT names the first missing step. The tutor
# only chooses the words to say it in the learner's language.
#
# Rule 2 needs a course of several chapters to bite; with one chapter
# it holds trivially and is NOT claimed as tested (E3 tests it).
#
# No language model is involved, and none is needed (law 6).

func StzTutorQ(poExercise, pcLearnerFolder, pcLang)
	return new stzTutor(poExercise, pcLearnerFolder, pcLang)

func _EduHasAnyWord(pcText, pacWords)
	_c_ = StzLower(pcText)
	_nL_ = len(pacWords)
	for _i_ = 1 to _nL_
		if StzFindFirst(StzLower(pacWords[_i_]), _c_) > 0
			return 1
		ok
	next
	return 0

  #=====================================================#
 #  WHAT THE TUTOR AND THE CHECKER SAY, IN 4 LANGUAGES  #
#=====================================================#

# No template carries code. The fr / ar / ha wording is a draft awaiting
# a native reviewer (plan, section F). %1 is filled with the learner's
# OWN material (their error line, or what their program printed).

func _EduSay(pcLang, pcKey, pcArg)
	_aT_ = _EduTemplates()
	_cLang_ = StzLower(pcLang)
	_nL_ = len(_aT_)
	for _i_ = 1 to _nL_
		if _aT_[_i_][1] = pcKey and _aT_[_i_][2] = _cLang_
			return StzReplace(_aT_[_i_][3], "%1", pcArg)
		ok
	next
	StzRaise("No '" + pcKey + "' text in '" + pcLang + "' (law 7: a missing translation is red, never English).")

func _EduTemplates()
	return [
	[ "refuse", "en", "I will not write the answer for you: that is the one thing a tutor must never do." ],
	[ "refuse", "fr", "Je n'écrirai pas la réponse à votre place : c'est la seule chose qu'un tuteur ne doit jamais faire." ],
	[ "refuse", "ar", "لن أكتب الجواب بدلًا منك: هذا هو الشيء الوحيد الذي لا يجوز للمعلّم أن يفعله أبدًا." ],
	[ "refuse", "ha", "Ba zan rubuta maka amsar ba: wannan shi ne abu ɗaya da malami ba zai taɓa yi ba." ],

	[ "confirm", "en", "I can only confirm what the checker has run. Submit it, and the run will say." ],
	[ "confirm", "fr", "Je ne peux confirmer que ce que le vérificateur a exécuté. Soumettez-le, et l'exécution le dira." ],
	[ "confirm", "ar", "لا أستطيع أن أؤكد إلا ما شغّله المدقّق. قدّمه، وسيقول التشغيل." ],
	[ "confirm", "ha", "Zan iya tabbatar da abin da mai dubawa ya gudanar kawai. Ka miƙa shi, gudanarwar za ta faɗa." ],

	[ "try-first", "en", "Try first. Write your attempt and submit it; then I will tell you what is still missing, as a question." ],
	[ "try-first", "fr", "Essayez d'abord. Écrivez votre tentative et soumettez-la ; je vous dirai ensuite ce qui manque encore, sous forme de question." ],
	[ "try-first", "ar", "حاول أولًا. اكتب محاولتك وقدّمها، ثم أخبرك بما ينقص بعدُ، في صورة سؤال." ],
	[ "try-first", "ha", "Ka fara gwadawa. Rubuta ƙoƙarinka ka miƙa shi; sannan zan faɗa maka abin da ya rage, a matsayin tambaya." ],

	[ "gap-finds", "en", "Where are the repeated items? Which line of your program asks for their positions? (why: the mental model finds before it applies)" ],
	[ "gap-finds", "fr", "Où sont les éléments répétés ? Quelle ligne de votre programme demande leurs positions ? (pourquoi : le modèle mental trouve avant d'agir)" ],
	[ "gap-finds", "ar", "أين العناصر المكررة؟ أيّ سطر في برنامجك يسأل عن مواضعها؟ (لماذا: النموذج الذهني يبحث قبل أن يطبّق)" ],
	[ "gap-finds", "ha", "Ina abubuwan da aka maimaita? Wane layi a shirinka yake tambayar wurarensu? (dalili: tsarin tunani yana nemo kafin ya aiwatar)" ],

	[ "gap-applies", "en", "You found them. What does your program do at those positions? (why: finding is not yet acting)" ],
	[ "gap-applies", "fr", "Vous les avez trouvés. Que fait votre programme à ces positions ? (pourquoi : trouver n'est pas encore agir)" ],
	[ "gap-applies", "ar", "لقد وجدتها. ماذا يفعل برنامجك في تلك المواضع؟ (لماذا: الإيجاد ليس تطبيقًا بعدُ)" ],
	[ "gap-applies", "ha", "Ka same su. Me shirinka yake yi a waɗannan wurare? (dalili: nemowa ba aiwatarwa ba ce tukuna)" ],

	[ "gap-asks", "en", "Before acting: does your list contain what you are looking for, and how many times? (why: ask before you act)" ],
	[ "gap-asks", "fr", "Avant d'agir : votre liste contient-elle ce que vous cherchez, et combien de fois ? (pourquoi : demander avant d'agir)" ],
	[ "gap-asks", "ar", "قبل أن تتصرّف: هل تحتوي قائمتك على ما تبحث عنه، وكم مرة؟ (لماذا: اسأل قبل أن تتصرّف)" ],
	[ "gap-asks", "ha", "Kafin ka aiwatar: shin jerinka yana ɗauke da abin da kake nema, kuma sau nawa? (dalili: ka tambaya kafin ka aiwatar)" ],

	[ "look-output", "en", "Look at what your program printed, line by line. Which item still appears twice, or in the wrong place?" ],
	[ "look-output", "fr", "Regardez ce que votre programme a affiché, ligne par ligne. Quel élément apparaît encore deux fois, ou à la mauvaise place ?" ],
	[ "look-output", "ar", "انظر إلى ما طبعه برنامجك، سطرًا سطرًا. أيّ عنصر ما زال يظهر مرتين، أو في غير مكانه؟" ],
	[ "look-output", "ha", "Duba abin da shirinka ya buga, layi bayan layi. Wane abu har yanzu yake bayyana sau biyu, ko a wurin da bai dace ba?" ],

	[ "gap-error", "en", "Your program stopped with an error before it could answer. Read the first error line: which name did Ring not recognise?" ],
	[ "gap-error", "fr", "Votre programme s'est arrêté sur une erreur avant de répondre. Lisez la première ligne d'erreur : quel nom Ring n'a-t-il pas reconnu ?" ],
	[ "gap-error", "ar", "توقف برنامجك بخطأ قبل أن يجيب. اقرأ أول سطر خطأ: أيّ اسم لم يتعرّف عليه Ring؟" ],
	[ "gap-error", "ha", "Shirinka ya tsaya da kuskure kafin ya amsa. Karanta layin kuskure na farko: wane suna Ring bai gane ba?" ],

	[ "passed", "en", "You passed, and the checker proved it by running your program. Now compare your way with others: ask me about any method." ],
	[ "passed", "fr", "Vous avez réussi, et le vérificateur l'a prouvé en exécutant votre programme. Comparez maintenant votre manière avec d'autres : interrogez-moi sur n'importe quelle méthode." ],
	[ "passed", "ar", "لقد نجحت، وأثبت المدقّق ذلك بتشغيل برنامجك. قارن الآن طريقتك بطرق أخرى: اسألني عن أي دالة." ],
	[ "passed", "ha", "Ka ci nasara, kuma mai dubawa ya tabbatar da haka ta hanyar gudanar da shirinka. Yanzu kwatanta hanyarka da wasu: tambaye ni game da kowace hanya." ],

	[ "why-passed-decl", "en", "The court judged your declaration, and every promise of the exercise was kept." ],
	[ "why-passed-decl", "fr", "La cour a jugé votre déclaration, et toutes les promesses de l'exercice ont été tenues." ],
	[ "why-passed-decl", "ar", "حكمت المحكمة على تصريحك، وتحققت كل وعود التمرين." ],
	[ "why-passed-decl", "ha", "Kotu ta yi hukunci a kan bayaninka, kuma duk alkawuran aikin sun cika." ],

	[ "why-diverged-decl", "en", "The court judged your declaration, and its verdict is not yet what the task asks. It said: %1" ],
	[ "why-diverged-decl", "fr", "La cour a jugé votre déclaration, et son verdict n'est pas encore ce que la tâche demande. Elle a dit : %1" ],
	[ "why-diverged-decl", "ar", "حكمت المحكمة على تصريحك، وحكمها ليس بعدُ ما تطلبه المهمة. قالت: %1" ],
	[ "why-diverged-decl", "ha", "Kotu ta yi hukunci a kan bayaninka, amma hukuncinta ba shi ne abin da aikin ke nema ba tukuna. Ta ce: %1" ],

	[ "why-passed", "en", "Every promise of the exercise was kept when your program ran." ],
	[ "why-passed", "fr", "Toutes les promesses de l'exercice ont été tenues quand votre programme s'est exécuté." ],
	[ "why-passed", "ar", "تحققت كل وعود التمرين عندما شُغّل برنامجك." ],
	[ "why-passed", "ha", "Duk alkawuran aikin sun cika lokacin da aka gudanar da shirinka." ],

	[ "why-error", "en", "Your program stopped with an error: %1" ],
	[ "why-error", "fr", "Votre programme s'est arrêté sur une erreur : %1" ],
	[ "why-error", "ar", "توقف برنامجك بخطأ: %1" ],
	[ "why-error", "ha", "Shirinka ya tsaya da kuskure: %1" ],

	[ "why-diverged", "en", "Your program ran, but what it printed is not yet what the task asks. It printed: %1" ],
	[ "why-diverged", "fr", "Votre programme s'est exécuté, mais ce qu'il affiche n'est pas encore ce que la tâche demande. Il a affiché : %1" ],
	[ "why-diverged", "ar", "شُغّل برنامجك، لكن ما طبعه ليس بعدُ ما تطلبه المهمة. لقد طبع: %1" ],
	[ "why-diverged", "ha", "An gudanar da shirinka, amma abin da ya buga ba shi ne abin da aikin ke nema ba tukuna. Ya buga: %1" ],

	[ "cell-browser", "en", "Runs in the browser" ],
	[ "cell-browser", "fr", "S'exécute dans le navigateur" ],
	[ "cell-browser", "ar", "تعمل في المتصفح" ],
	[ "cell-browser", "ha", "Tana gudana a cikin burauza" ],

	[ "cell-desktop", "en", "Runs on the desktop with Softanza" ],
	[ "cell-desktop", "fr", "S'exécute sur l'ordinateur avec Softanza" ],
	[ "cell-desktop", "ar", "تعمل على الحاسوب مع سوفتانزا" ],
	[ "cell-desktop", "ha", "Tana gudana a kwamfuta tare da Softanza" ],

	[ "cell-no-output", "en", "This page stores no output. Run the cell to see what it prints." ],
	[ "cell-no-output", "fr", "Cette page ne stocke aucun résultat. Exécutez la cellule pour voir ce qu'elle affiche." ],
	[ "cell-no-output", "ar", "لا تخزّن هذه الصفحة أي نتيجة. شغّل الخلية لترى ما تطبعه." ],
	[ "cell-no-output", "ha", "Wannan shafin ba ya ajiye sakamako. Gudanar da ɗakin don ganin abin da yake bugawa." ],

	[ "exercise-note", "en", "Checked by running your program on the desktop, never by reading it." ],
	[ "exercise-note", "fr", "Vérifié en exécutant votre programme sur l'ordinateur, jamais en le lisant." ],
	[ "exercise-note", "ar", "يُتحقق منه بتشغيل برنامجك على الحاسوب، لا بقراءته أبدًا." ],
	[ "exercise-note", "ha", "Ana tabbatarwa ta hanyar gudanar da shirinka a kwamfuta, ba ta hanyar karanta shi ba." ]
	]

class stzTutor from stzObject

	@oExercise
	@cLearnerFolder = ""
	@cLang = "en"
	@acForbidden = []
	@nFiltered = 0
	@cLastGap = ""

	def init(poExercise, pcLearnerFolder, pcLang)
		@oExercise = poExercise
		@cLearnerFolder = pcLearnerFolder
		@cLang = pcLang
		@acForbidden = poExercise.ForbiddenWords()

	def Language()
		return @cLang

	def FilteredCount()
		return @nFiltered

	def LastGap()
		return @cLastGap

	def ForbiddenWords()
		return @acForbidden

	def Ask(pcQuestion)
		_oL_ = new stzLearner(@cLearnerFolder)
		_cEx_ = @oExercise.Id()
		@cLastGap = ""
		_cHead_ = ""
		if This._AsksForConfirmation(pcQuestion)
			_cHead_ = _EduSay(@cLang, "confirm", "") + " "
		but This._AsksForTheAnswer(pcQuestion)
			_cHead_ = _EduSay(@cLang, "refuse", "") + " "
		ok

		if _oL_.HasPassed(_cEx_)
			return _EduSay(@cLang, "passed", "")
		ok

		if NOT _oL_.HasTried(_cEx_)
			return This._Filter(_cHead_ + _EduSay(@cLang, "try-first", ""))
		ok

		if _oL_.LastVerdict(_cEx_) = "error"
			return This._Filter(_cHead_ + _EduSay(@cLang, "gap-error", ""))
		ok

		@cLastGap = This.GapIn(read(_oL_.WorkFile(_cEx_)))
		if @cLastGap = ""
			return This._Filter(_cHead_ + _EduSay(@cLang, "look-output", ""))
		ok
		return This._Filter(_cHead_ + _EduSay(@cLang, "gap-" + @cLastGap, ""))

	# The first missing step, named by the wise-coding conversation.
	def GapIn(pcCode)
		_oKB_ = new stzKnowledgeGraph("attempt")
		_c_ = StzLower(pcCode)
		if StzFindFirst("contains", _c_) > 0 or StzFindFirst("numberof", _c_) > 0 or StzFindFirst("count", _c_) > 0
			_oKB_.KnowRelation("attempt", "asks", "yes")
		ok
		if StzFindFirst("find", _c_) > 0
			_oKB_.KnowRelation("attempt", "finds", "yes")
		ok
		if StzFindFirst("remove", _c_) > 0 or StzFindFirst("replace", _c_) > 0
			_oKB_.KnowRelation("attempt", "applies", "yes")
		ok
		_oGoal_ = StzGoalQ()
		_acNeeds_ = @oExercise.NeededSteps()
		_nL_ = len(_acNeeds_)
		for _i_ = 1 to _nL_
			_oGoal_.RequireOne("attempt", _acNeeds_[_i_])
		next
		_oKB_.AddConversationQ("tutor").SetGoal(_oGoal_)
		if len(_oKB_.GapsIn("tutor")) = 0
			return ""
		ok
		_aQ_ = _oKB_.AskInXT("tutor")
		return _aQ_[:relation]

	def _AsksForConfirmation(pcQ)
		return _EduHasAnyWord(pcQ, [ "confirm", "confirme", "correct?", "is it right", "est-ce juste",
			"أكد", "هل هذا صحيح", "tabbatar" ])

	def _AsksForTheAnswer(pcQ)
		return _EduHasAnyWord(pcQ, [ "answer", "solution", "give me", "show me the code", "write it",
			"write the code", "pretend", "ignore", "the code", "réponse", "donne", "montre", "écris",
			"الجواب", "الحل", "أعطني", "اكتب", "amsa", "bani", "rubuta" ])

	def _Filter(pcReply)
		_c_ = pcReply
		_nL_ = len(@acForbidden)
		for _i_ = 1 to _nL_
			if StzFindFirst(StzLower(@acForbidden[_i_]), StzLower(_c_)) > 0
				_c_ = StzReplaceCS(_c_, @acForbidden[_i_], "...", 0)
				@nFiltered++
			ok
		next
		return _c_

