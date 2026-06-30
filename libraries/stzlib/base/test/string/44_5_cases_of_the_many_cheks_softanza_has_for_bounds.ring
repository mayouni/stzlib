load "../../stzBase.ring"
load "../_narrated.ring"

# Five spellings of "is X bounded by Y". IsBoundedBy accepts a single string bound
# (-> [c,c]) or an [open,close] pair. The XT forms take :In = host: IsBoundedByXT
# asks whether THIS substring is bounded by `bound` inside host; IsBoundOfXT /
# AreBoundsOfXT ask whether THIS string(s) bound a substring inside host.
# Archive block #44.

Scenario("The many ways to check bounds")
	Then("'_world_' is bounded by '_'", Q("_world_").IsBoundedBy("_"), TRUE)
	Then("'/world\' is bounded by ['/','\']", Q("/world\").IsBoundedBy([ "/", "\" ]), TRUE)
	Then("'world' is bounded by '_' inside '_world_'",
		Q("world").IsBoundedByXT( "_", :In = "_world_" ), TRUE)
	Then("'world' is bounded by ['/','\'] inside '/world\'",
		Q("world").IsBoundedByXT( ["/","\"], :In = "/world\" ), TRUE)
	Then("'_' is a bound of 'world' inside the sentence",
		Q("_").IsBoundOfXT("world", :In = "Hello _world_ of Ring!"), TRUE)
	Then("['/','\'] are bounds of 'world' inside the sentence",
		Q(["/","\"]).AreBoundsOfXT("world", :In = "Hello /world\ of Ring!"), TRUE)
EndScenario()

Summary()
