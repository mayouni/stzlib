load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzGraphex -- the graph-pattern DSL
# (stzGraphex from stzGraph). Patterns like "{@Node(a) -> @Edge(x) ->
# @Node(b)}" are compiled to a pattern graph and matched against a target
# graph by flattening both to label branches and testing subsequence
# containment. Deterministic.
#
# Regression guards (all fixed this session):
#  - stzGraph PathsXT/_FindAllPathsDFS used stzleft() (a STRING op) to pop
#    a list element, panicking the string engine with @intFromFloat OOB;
#    Match() drove PathsXT so every Match crashed. Now threads fresh path
#    copies.
#  - Label/set extraction leaked the closing ')'/'}' into the value
#    (@StzMid count was nEnd-1, not the inter-delimiter span).
#  - Matching used Ring's case-sensitive '='; the documented default is
#    case-INsensitive, with a per-token "@cs:" marker for case-sensitive.
#  - Property constraints ({age:>:25}) were parsed but never evaluated.
#  - A char-indexing numeric-check helper corrupted the VM ("Bad parameter
#    type!" on the next build); replaced with isNumber()-based compare.

#============================================================#
#  PATTERN COMPILATION                                       #
#============================================================#

Scenario("A pattern compiles to a pattern graph")
    Given("the single-node pattern {@Node(a)} over a 1-node graph")
    g = G1()
    gx = new stzGraphex("{@Node(a)}", g)
    Then("the pattern graph has 1 node", gx.NumberOfNodes(), 1)
EndScenario()

Scenario("A sequence pattern compiles to N nodes")
    Given("{@Node(a) -> @Edge(x) -> @Node(b)} over a->b")
    g = G2()
    gx = new stzGraphex("{@Node(a) -> @Edge(x) -> @Node(b)}", g)
    Then("the pattern graph has 3 nodes", gx.NumberOfNodes(), 3)
EndScenario()

#============================================================#
#  BASIC MATCHING                                            #
#============================================================#

Scenario("A present node label matches")
    Given("a graph with a node labelled 'Start'")
    g = GLabels()
    Then("{@Node(Start)} matches", (new stzGraphex("{@Node(Start)}", g)).Match(g), TRUE)
EndScenario()

Scenario("An absent node label does not match")
    Given("the same graph")
    g = GLabels()
    Then("{@Node(zzz)} does not match", (new stzGraphex("{@Node(zzz)}", g)).Match(g), FALSE)
EndScenario()

Scenario("A sequence matches when present as a subsequence")
    Given("Start -Flows-> PROCESS -COMPLETES-> end")
    g = GLabels()
    Then("{@Node(start) -> @Edge(flows) -> @Node(process)} matches",
        (new stzGraphex("{@Node(start) -> @Edge(flows) -> @Node(process)}", g)).Match(g), TRUE)
EndScenario()

#============================================================#
#  CASE SENSITIVITY                                          #
#============================================================#

Scenario("Matching is case-insensitive by default")
    Given("a graph with mixed-case labels Start / PROCESS")
    g = GLabels()
    Then("lower-case pattern still matches", (new stzGraphex("{@Node(start)}", g)).Match(g), TRUE)
    Then("upper-case pattern still matches", (new stzGraphex("{@Node(PROCESS)}", g)).Match(g), TRUE)
EndScenario()

Scenario("@cs: forces case-sensitive matching")
    Given("a graph with both 'Start' and 'start' nodes")
    g = GCase()
    Then("@cs: exact 'Start' matches", (new stzGraphex("{@cs:@Node(Start)}", g)).Match(g), TRUE)
    Then("@cs: exact 'start' matches", (new stzGraphex("{@cs:@Node(start)}", g)).Match(g), TRUE)
    Then("@cs: 'START' does not match (no such case)", (new stzGraphex("{@cs:@Node(START)}", g)).Match(g), FALSE)
EndScenario()

Scenario("Case sensitivity is per-token")
    Given("User -Promotes-> ADMIN")
    g = GMixed()
    Then("cs 'User' + ci 'admin' matches",
        (new stzGraphex("{@cs:@Node(User) -> @Edge -> @Node(admin)}", g)).Match(g), TRUE)
    Then("cs 'user' (wrong case) fails",
        (new stzGraphex("{@cs:@Node(user) -> @Edge -> @Node(admin)}", g)).Match(g), FALSE)
EndScenario()

#============================================================#
#  NEGATION + ALTERNATION                                    #
#============================================================#

Scenario("Negation forbids a label on the matched branch")
    Given("start -> middle -> done")
    g = GNeg()
    Then("'start then NOT middle' fails (middle is present)",
        (new stzGraphex("{@Node(start) -> @!Node(middle)}", g)).Match(g), FALSE)
    Then("'start then NOT ghost' matches (ghost absent)",
        (new stzGraphex("{@Node(start) -> @!Node(ghost)}", g)).Match(g), TRUE)
EndScenario()

Scenario("Alternation matches when any branch is present")
    Given("a -> b -> c")
    g = GAlt()
    Then("(b|x) in the middle matches",
        (new stzGraphex("{@Node(a) -> (@Node(b)|@Node(x)) -> @Node(c)}", g)).Match(g), TRUE)
    Then("(y|x) in the middle fails (neither present)",
        (new stzGraphex("{@Node(a) -> (@Node(y)|@Node(x)) -> @Node(c)}", g)).Match(g), FALSE)
EndScenario()

#============================================================#
#  PROPERTY CONSTRAINTS                                      #
#============================================================#

Scenario("Numeric property comparisons")
    Given("Alice age 30, Bob age 20, Charlie age 35")
    g = GAges()
    Then("{age:>:25} matches (Alice/Charlie)", (new stzGraphex("{@Node{age:>:25}}", g)).Match(g), TRUE)
    Then("{age:>:40} fails (nobody)",        (new stzGraphex("{@Node{age:>:40}}", g)).Match(g), FALSE)
    Then("{age:<:25} matches (Bob)",         (new stzGraphex("{@Node{age:<:25}}", g)).Match(g), TRUE)
    Then("{age:=:30} matches (Alice)",       (new stzGraphex("{@Node{age:=:30}}", g)).Match(g), TRUE)
    Then("{age:=:99} fails",                 (new stzGraphex("{@Node{age:=:99}}", g)).Match(g), FALSE)
EndScenario()

Scenario("Multiple property constraints (AND)")
    Given("Alice age 30 score 85, Bob age 25 score 90")
    g = GScores()
    Then("{age:>:26;score:>:80} matches (Alice)",
        (new stzGraphex("{@Node{age:>:26;score:>:80}}", g)).Match(g), TRUE)
    Then("{age:>:26;score:>:95} fails (Alice fails score)",
        (new stzGraphex("{@Node{age:>:26;score:>:95}}", g)).Match(g), FALSE)
EndScenario()

#============================================================#
#  MATCH CACHE                                               #
#============================================================#

Scenario("Results are cached by target-graph signature")
    Given("a pattern matched against two different graphs")
    g1 = G1()
    g2 = G2()
    gx = new stzGraphex("{@Node(a)}", g1)
    gx.Match(g1)
    gx.Match(g1)
    gx.Match(g2)
    Then("two distinct signatures are cached", gx.CacheStats()[:entries], 2)
    Then("the repeat lookup counted as a hit", gx.CacheStats()[:hits], 1)
EndScenario()

Scenario("SetCacheSize bounds the cache (FIFO eviction)")
    Given("a fresh cache capped at size 1")
    g1 = G1()
    g2 = G2()
    gx = new stzGraphex("{@Node(a)}", g1)
    gx.SetCacheSize(1)
    gx.ClearCache()
    gx.Match(g1)
    gx.Match(g2)
    Then("only the most recent entry remains", gx.CacheStats()[:entries], 1)
    Then("CacheInfo reports the cap", gx.CacheInfo()[:maxsize], 1)
EndScenario()

Summary()

#============================================================#
#  GRAPH FIXTURES                                            #
#============================================================#

func G1()
    g = new stzGraph("g1")
    g.AddNode("a")
    return g

func G2()
    g = new stzGraph("g2")
    g.AddNode("a")
    g.AddNode("b")
    g.AddEdge("a", "b")
    return g

func GLabels()
    g = new stzGraph("Mixed")
    g.AddNodeXT(:a, "Start")
    g.AddNodeXT(:b, "PROCESS")
    g.AddNodeXT(:c, "end")
    g.AddEdgeXT(:a, :b, "Flows")
    g.AddEdgeXT(:b, :c, "COMPLETES")
    return g

func GCase()
    g = new stzGraph("CS")
    g.AddNodeXT(:a, "Start")
    g.AddNodeXT(:b, "start")
    g.AddEdgeXT(:a, :b, "flows")
    return g

func GMixed()
    g = new stzGraph("Mix")
    g.AddNodeXT(:a, "User")
    g.AddNodeXT(:b, "ADMIN")
    g.AddEdgeXT(:a, :b, "Promotes")
    return g

func GNeg()
    g = new stzGraph("N")
    g.AddNode("start")
    g.AddNode("middle")
    g.AddNode("done")
    g.AddEdge("start", "middle")
    g.AddEdge("middle", "done")
    return g

func GAlt()
    g = new stzGraph("A")
    g.AddNode("a")
    g.AddNode("b")
    g.AddNode("c")
    g.AddEdge("a", "b")
    g.AddEdge("b", "c")
    return g

func GAges()
    g = new stzGraph("Users")
    g.AddNodeXTT(:u1, "Alice", [:age = 30])
    g.AddNodeXTT(:u2, "Bob", [:age = 20])
    g.AddNodeXTT(:u3, "Charlie", [:age = 35])
    return g

func GScores()
    g = new stzGraph("Complex")
    g.AddNodeXTT(:u1, "Alice", [:age = 30, :score = 85])
    g.AddNodeXTT(:u2, "Bob", [:age = 25, :score = 90])
    return g
