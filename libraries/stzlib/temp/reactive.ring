load "../max/stzmax.ring"

profon()

change = [ :button = "espresso" ]
f1 = func change { if change[:button] = "espresso" makeEspresso() ok }

aList = [
	:type = "button press",
	:action = f1
]

? @@NL( aList )

call f1(null)

proff()

func makeEspresso()
	? "Starting your expresso!"

/*---------

profon()

o1 = new CoffeeMachine
o1 {

	# Add knwoan patterns
	Learn([
		:type = "button press",
		:action = func change { if change[:button] = "espresso" makeEspresso() ok }

	])

? @@NL(context)

}


proff()

class CoffeeMachine from UnifiedSystem


	def UpdateContext()
		context = "xyz"

	def Context()
		return context

		
############################################################""

# Base system that unifies static and dynamic behaviors
Class UnifiedSystem
    context = []
    
    def init()
        context = [
            :known = [],      # Static knowledge
            :current = [],    # Runtime state
            :patterns = []    # Learned behaviors
        ]

    
    def learn(pattern)

//	if not len(context["patterns"]) = 0

       	 	add(context["patterns"], pattern)
//    	ok

    def process(change)
        # Apply known patterns
        for pattern in context["patterns"]
            if matchesPattern(change, pattern)
                applyPattern(pattern, change)
            ok
        next
        
        # Update current state
        context["current"] = change
        
        # Learn if new
        if isNovel(change)
            learn(extractPattern(change))
        ok
    
    private
    
    def matchesPattern(change, pattern)
        return change["type"] = pattern["type"]
    
    def applyPattern(pattern, change)
        if pattern["action"]
            pattern["action"](change)
        ok
    
    def isNovel(change)
        for pattern in context["patterns"]
            if matchesPattern(change, pattern)
                return false
            ok
        next
        return true
    
    def extractPattern(change)
        return [
            :type = change["type"],
            :action = change["action"]
        ]
