load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the JSON helpers -- predicates and
# the list <-> JSON-string conversions. Deterministic.

Scenario("JSON predicates")
    Then("a flat keyed list is a JSON list", IsJsonList([ :a = 10, :b = 20 ]), TRUE)
    Then("a list with an unkeyed nested element is not", IsJsonList([ :a = 10, [ :d = 30 ] ]), FALSE)
    Then("a well-formed JSON string is recognised", IsJsonString('{ "a": 1, "b": 2 }'), TRUE)
    Then("malformed text is rejected", IsJsonString('{not json'), FALSE)
EndScenario()

Scenario("List to JSON string")
    Then("ListToJson emits compact JSON", ListToJson([ :name = "John", :age = 30 ]), '{"name":"John","age":30}')
    Then("nested keyed lists become nested objects", ListToJson([ :a = 1, :c = [ :d = 30 ] ]), '{"a":1,"c":{"d":30}}')
EndScenario()

Scenario("JSON string to list")
    Then("JsonToList parses to key/value pairs", ListEq(JsonToList('{"name": "John", "age": 30 }'), [ [ "name", "John" ], [ "age", 30 ] ]), TRUE)
    Then("nested objects parse to nested pairs", ListEq(JsonToList('{"a": 1, "c": {"d": 30}}'), [ [ "a", 1 ], [ "c", [ [ "d", 30 ] ] ] ]), TRUE)
    Then("arrays parse to plain lists", ListEq(JsonToList('{"nums": [1, 2, 3]}'), [ [ "nums", [ 1, 2, 3 ] ] ]), TRUE)
EndScenario()

Scenario("Round-trips")
    Then("list -> JSON -> list is identity", ListEq(JsonToList(ListToJson([ :x = 1, :y = 2 ])), [ [ "x", 1 ], [ "y", 2 ] ]), TRUE)
EndScenario()

Summary()

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
