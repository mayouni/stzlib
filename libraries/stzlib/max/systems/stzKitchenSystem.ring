load "../stzmax.ring"

# Try it out

kitchen = new Kitchen

kitchen.addIngredient("tomato", "fresh")
? "Kitchen has: " + kitchen.ingredients[1]["name"] + nl


kitchen.onEvent("ingredient_added", func(data) {
    see "Added: " + data["name"] + nl }
)

? kitchen.triggerEvent("ingredient_added", [ "name": "tomato" ])


class Kitchen
	ingredients = []
    	eventHandlers = []

	def init()
		ingredients = []
		eventHandlers = []
    
	def addIngredient(name, state)

		ingredients + [
			:name = name,
			:state = state
		]

	def OnEvent(eventName, handler)
? "hi"
? @@(eventHandlers[eventName])
		if eventHandlers[eventName] = NULL
			eventHandlers + [ eventName, [] ]
		ok

		eventHandlers[eventName] + handler
? @@(eventHandlers)

	def triggerEvent(eventName, data)
		if NOT eventHandlers[eventName] = NULL
			for handler in eventHandlers[eventName]
				handler(data)
			next
		ok
