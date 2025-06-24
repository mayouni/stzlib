

/*-----------------#
# IMPLEMENTATION  #
#-----------------#
*/
Class OrderSystem from UnifiedSystem

	skills = [

		[
			:name = "new_order",

         		:action = '{
           		 	if @[:payment] = "verified"
                			result = "Processing order #" + @[:id]
            			ok
         		}'
		]
    	]

class SmartHome from UnifiedSystem

	skills = [

		[
			:name = "motion",

         		:action = '{
            			if @[:location] = "living_room"
                			result = "Turning on lights"
           		 	ok
         		}'
		],

        	[
			:name = "temperature",

         		:action = '{
            			if @[:value] > 25
               				result = "Starting AC"
            			ok
         		}'
		]
    	]

Class CoffeeMachine from UnifiedSystem

	skills = [

		[
			:name = "press_button",

			:action = '{
				if @[:label] = "espresso"
					result = @[:msg]
				ok
		 	}'
		],

		[
			:name = "water_level",

		 	:action = '{
				if @[:level] < 20
					result = "Please refill water"
				ok
		 	}'
		]
	]

Class UnifiedSystem
	tasks = []
	skills = []	# Knowan behaviors

	history = []
	aPool = []
	state = :ON	# or :OFF or :ERR or :IRR

	minTaskSuccessRate = 0.99

	minSystemSuccessRate = 0.99
	systemSuccessHistory = []

	  #-------------------------#
	 #  MANAGING SYSTEM STATE  #
	#-------------------------#

	def State()
		return state

	def Start()
		state = :ON

	def Stop()
		state = :OFF


	  #--------------------#
	 #  SKILLS UTILITIES  #
	#--------------------#

	def Skills()
		return skills()

	def SkillByName(cName)
		for skill in skills
			if skill[:name] = cName
				return skill
			ok
		next
		return []

	  #-------------------#
	 #  TASKS UTILITIES  #
	#-------------------#

	def TaskByname(cName)
		for task in tasks
			if task[:name] = cName
				return task
			ok
		next
		return []

	def Task(@)

		# Gets the unified task data made by the
		# version we may have yet in the system
		# skillset and the one provide here

		TaskByName(@)

	def IsTask(@)

//		@ = This.Task(@)

		if NOT isList(@)
			return _FALSE_
		ok

		if NOT len(@) >= 3
			return _FALSE_
		ok

		if NOT IsHashList(@)
			return _FALSE_
		ok

		if NOT ( IsStzObject(@[:object]) and
			 isString(@[:name]) and @[:name] != _NULL_ and
			 isString(@[:action]) and @[:action] != _NULL_ )

			StzRaise("Invalid task format. The task must include 'object', 'name' and 'code' fields.")
		ok

		return _TRUE_

	def IsNovelTask(@) # @ abbreviation of a task

		if NOT IsTask(@)
			StzRaise("Syntax error! You must provide a well formatted task.")
		ok

		for Skill in skills
			if @[:name] = Skill[:name]
				return _FALSE_
			ok
		next

		return _TRUE_

		def IsNovel(@)
			return This.IsNovelTask(@)
			
	  #-----------------------------------#
	 #  DEFINING A TASK TO BE PROCESSED  #
	#-----------------------------------#
	
	def processTask(@)

		@ = Task(@)

		result = _NULL_

		if This.isNovel(@)
			skills + [
				:name = @[:name],
				:action = @[:action]
			]

		else

			Skill = SkillByname(@[:name])

			if Skill[:action] != ""
				@ + [ "task", Skill[:action] ]
			ok

		ok

		aPool + @

	  #-------------------------------#
	 #  EXECUTING THE PIPE OF TASKS  #
	#-------------------------------#

	def RunTasks()

		# Checking the state of the system before anything

		CheckSystemState()

		# Qualify tasks : tasks that are not yet qualified are
		# analyzed and get their @criticity set to:low, :normal, or :high

//		QualifyTasks()

		# Executing the pool of tasks

		while _TRUE_

			_nLen_ = len(aPool)

			if _nLen_ = 0
				exit
			ok

			_aFirstTask_ = aPool[1]

			cCode = _aFirstTask_[:action]

			oCode = new stzString(cCode)
			oCode.Trim()

			if oCode.IsBoundedBy([ "{", "}" ])
				cCode = oCode.TheseBoundsRemoved("{", "}")
			ok

			cCode = ring_substr2(cCode, "@", "_aFirstTask_")

			result = ""
			if cCode != ""
				eval(cCode)
			ok

			history + [ now(), _aFirstTask_[:name], _aFirstTask_[:value], result ]

			del(aPool, 1)
		end

		def ExecuteTasks()
			This.RunTasks()

		def Run()
			This.RunTasks()

		def Execute()
			This.RunTasks()

	#-------------------------------#
	#  MANAGING THE SYSTEM SUCCESS  #
	#-------------------------------#

	def MinSystemSuccessRate()
		return minSystemSuccessRate

	def SystemSuccessRate()
		# Calculate the system success rate based on the tasks success rates

	def SystemSuccessHistory()
		return systemSuccessHistory

	def CheckSystemState()

		# Checking the state itself

		switch State()
		on :ON
			// Just do normal processing
		on :OFF
			return _NULL_

		on :ERR
			raise(This.Error())

		on :IRR
			? "WARNING: SYSTEM IS IN AN IRREGULAR STATE!" + NL
		other
			raise("Unsupported state.")
		off

		# If the system is functioning (in ON or IRR states),
		# then check the current system success rate

		if This.SystemSuccessRate() < This.MinSystemSuccessRate()

			# if this low performance has been experienced in % of
			# the last @n tasks executions, then set it to IRR state


		ok

	#------------------------------#
	#  MANAGING TASK SUCCESS RATE  #
	#------------------------------#

	def MinTaskSuccessRate()
		return minTaskSuccessRate


	def IsSkillabale(@)

		# A task can be promoted to a skill if it has been experienced
		# by the system, at least @n times before and executed with success

		# ~> The idea is that the system does not accept any task to
		# be included in its skillset, because the skills will be
		# resusable in all future operation and will impact the quality
		# of all the system

		if This.TaskSuccesRate(@) > MinSuccessRate()

		ok
