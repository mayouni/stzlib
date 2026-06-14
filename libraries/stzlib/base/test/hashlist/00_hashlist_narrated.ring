load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the hashlist layer -- the global
# safe-access helpers (HasKey/HasKeys/HasKeysXT/HasPath) and the
# stzHashList object (keys/values/lookups). All deterministic.

Scenario("Safe key access on a flat hash")
    Given("a flat hash with name/email/age")
    aHash = [ :name = "Alice", :email = "alice@example.com", :age = 30 ]
    Then("HasKey('email') is TRUE",  HasKey(aHash, "email"), TRUE)
    Then("HasKey('none') is FALSE",  HasKey(aHash, "none"), FALSE)
    Then("HasKeys(name,age) is TRUE", HasKeys(aHash, [ "name", "age" ]), TRUE)
    Then("HasKeys(name,none,age) is FALSE", HasKeys(aHash, [ "name", "none", "age" ]), FALSE)
    Then("HasKeysXT(name,none,age) -> [TRUE,FALSE,TRUE]", ListEq(HasKeysXT(aHash, [ "name", "none", "age" ]), [ TRUE, FALSE, TRUE ]), TRUE)
EndScenario()

Scenario("Safe deep-path access on a nested hash")
    Given("a nested company hash")
    aDeep = [
        :name = "TechCorp",
        :departments = [
            :name = "Engineering",
            :teams = [
                :name = "Backend",
                :members = [ :name = "Alice", :role = "Senior Developer" ]
            ]
        ]
    ]
    Then("HasPath(departments/teams/members) is TRUE", HasPath(aDeep, ["departments", "teams", "members"]), TRUE)
    Then("HasPath with a bogus leaf is FALSE", HasPath(aDeep, ["departments", "teams", "nope"]), FALSE)
EndScenario()

Scenario("stzHashList keys, values and lookups")
    Given("a 4-pair hash list")
    o = Hl([ :one = "here", :two = "and", :three = "not", :four = "there" ])
    Then("NumberOfPairs is 4", o.NumberOfPairs(), 4)
    Then("Keys are [one,two,three,four]", ListEq(o.Keys(), [ "one", "two", "three", "four" ]), TRUE)
    Then("Values are [here,and,not,there]", ListEq(o.Values(), [ "here", "and", "not", "there" ]), TRUE)
    Then("value at :two is 'and'", o[:two], "and")
    Then("NthKey(2) is 'two'", o.NthKey(2), "two")
    Then("ContainsKey('three') is TRUE", o.ContainsKey("three"), TRUE)
    Then("ContainsKey('zzz') is FALSE", o.ContainsKey("zzz"), FALSE)
    Then("FindValue('not') -> [3]", ListEq(o.FindValue("not"), [ 3 ]), TRUE)
    Then("FindValues(here,and,there) -> [1,2,4]", ListEq(o.FindValues([ "here", "and", "there" ]), [ 1, 2, 4 ]), TRUE)
EndScenario()

Scenario("A named hash list")
    Given("a hash list named :myhash")
    o2 = StzNamedHashListQ(:myhash = [ :x = 10, :y = 20 ])
    Then("Name() is 'myhash'", o2.Name(), "myhash")
    Then("StzType() is 'stzhashlist'", o2.StzType(), "stzhashlist")
EndScenario()

Summary()

func Hl aPairs
    return new stzHashList(aPairs)

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
