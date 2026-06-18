load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzList -- a representative core of the
# engine-backed list surface: count, membership/find, reverse, sort, dedup,
# add, occurrences, slicing, reducers. Not exhaustive (the domain has ~670
# classic blocks); this is the run-for-real safety net for the central
# operations. Deterministic. Objects via Q(...).

Scenario("Count, membership and find")
    Given("the list [3,1,2,1]")
    o = Q([ 3, 1, 2, 1 ])
    Then("NumberOfItems is 4", o.NumberOfItems(), 4)
    Then("Contains(2) is TRUE", o.Contains(2), TRUE)
    Then("Contains(9) is FALSE", o.Contains(9), FALSE)
    Then("Find(2) -> [3]", ListEq(o.Find(2), [ 3 ]), TRUE)
    Then("Find(1) -> [2,4]", ListEq(o.Find(1), [ 2, 4 ]), TRUE)
    Then("NumberOfOccurrences(1) is 2", o.NumberOfOccurrences(1), 2)
EndScenario()

Scenario("Reverse, sort, dedup")
    Then("Reversed([1,2,3]) is [3,2,1]", ListEq(Q([1,2,3]).Reversed(), [ 3, 2, 1 ]), TRUE)
    Then("Sorted([3,1,2]) is [1,2,3]", ListEq(Q([3,1,2]).Sorted(), [ 1, 2, 3 ]), TRUE)
    Then("RemoveDuplicates keeps first occurrences", ListEq(Q([1,2,1,3,2]).RemoveDuplicatesQ().Content(), [ 1, 2, 3 ]), TRUE)
    Then("FindDuplicates returns 2nd+ occurrence positions", ListEq(Q([ "a","b","a","c","b","a" ]).FindDuplicates(), [ 3, 5, 6 ]), TRUE)
    Then("FindDuplicates is correct on nested-list items (engine-backed)", ListEq(Q([ [1,2], [3], [1,2], [3] ]).FindDuplicates(), [ 3, 4 ]), TRUE)
EndScenario()

Scenario("Add and slice")
    Then("AddQ(3) appends", ListEq(Q([1,2]).AddQ(3).Content(), [ 1, 2, 3 ]), TRUE)
    Then("FirstItem is 10", Q([10,20,30]).FirstItem(), 10)
    Then("LastItem is 30", Q([10,20,30]).LastItem(), 30)
    Then("Section(2,4) is [2,3,4]", ListEq(Q([1,2,3,4,5]).Section(2,4), [ 2, 3, 4 ]), TRUE)
EndScenario()

Scenario("Reducers and emptiness")
    Then("Sum([1,2,3,4]) is 10", Q([1,2,3,4]).Sum(), 10)
    Then("IsEmpty([]) is TRUE", Q([]).IsEmpty(), TRUE)
    Then("IsEmpty([1]) is FALSE", Q([1]).IsEmpty(), FALSE)
EndScenario()

Scenario("Indexing and slicing")
    Then("NthItem(3) of [10,20,30,40] is 30", Q([10,20,30,40]).NthItem(3), 30)
    Then("FirstNItems(2) of [1..5] is [1,2]", ListEq(Q([1,2,3,4,5]).FirstNItems(2), [ 1, 2 ]), TRUE)
    Then("LastNItems(2) of [1..5] is [4,5]", ListEq(Q([1,2,3,4,5]).LastNItems(2), [ 4, 5 ]), TRUE)
    Then("Flattened([[1,2],[3,[4,5]]]) is [1,2,3,4,5]", ListEq(Q([ [1,2],[3,[4,5]] ]).Flattened(), [ 1, 2, 3, 4, 5 ]), TRUE)
EndScenario()

Scenario("Numeric aggregates")
    Then("Min([3,1,2]) is 1", Q([3,1,2]).Min(), 1)
    Then("Max([3,1,2]) is 3", Q([3,1,2]).Max(), 3)
    Then("Product([1,2,3,4]) is 24", Q([1,2,3,4]).Product(), 24)
    Then("Average([2,4,6]) is 4", Q([2,4,6]).Average(), 4)
EndScenario()

Scenario("Set operations")
    Then("UnionWith([1,2,3],[3,4,5]) is [1,2,3,4,5]", ListEq(Q([1,2,3]).UnionWith([3,4,5]), [ 1, 2, 3, 4, 5 ]), TRUE)
    Then("DifferenceWith([1,2,3,4],[2,4]) is [1,3]", ListEq(Q([1,2,3,4]).DifferenceWith([2,4]), [ 1, 3 ]), TRUE)
    Then("IntersectWith([1,2,3],[2,3,4]) is [2,3]", ListEq(Q([1,2,3]).IntersectWith([2,3,4]), [ 2, 3 ]), TRUE)
    Then("ContainsAll([1,2,3],[1,3]) is TRUE", Q([1,2,3]).ContainsAll([1,3]), TRUE)
    Then("ContainsMany([1,2,3],[1,9]) is FALSE (9 absent)", Q([1,2,3]).ContainsMany([1,9]), FALSE)
EndScenario()

Scenario("Sorting descending")
    Then("SortedInDescending([1,3,2]) is [3,2,1]", ListEq(Q([1,3,2]).SortedInDescending(), [ 3, 2, 1 ]), TRUE)
EndScenario()

Scenario("Mutators modify in place")
    Given("a list to mutate")
    o1 = Q([ "a", "b", "c" ])
    o1.RemoveAt(2)
    Then("RemoveAt(2) -> [a,c]", ListEq(o1.Content(), [ "a", "c" ]), TRUE)
    o2 = Q([ "a", "b", "c" ])
    o2.InsertBefore(2, "X")
    Then("InsertBefore(2,X) -> [a,X,b,c]", ListEq(o2.Content(), [ "a", "X", "b", "c" ]), TRUE)
    Then("ReplaceAtQ(2,9) on [1,2,3] -> [1,9,3]", ListEq(Q([1,2,3]).ReplaceAtQ(2,9).Content(), [ 1, 9, 3 ]), TRUE)
EndScenario()

Scenario("Transform and conditional find")
    Then("Map('2*@item') on [1,2,3] -> [2,4,6]", ListEq(Q([1,2,3]).Map("2*@item"), [ 2, 4, 6 ]), TRUE)
    Then("Filter('@item > 2') on [1..4] -> [3,4]", ListEq(Q([1,2,3,4]).Filter("@item > 2"), [ 3, 4 ]), TRUE)
    Then("CountW('@item > 2') on [1..4] is 2", Q([1,2,3,4]).CountW("@item > 2"), 2)
    Then("FindFirst(2) in [1,2,3,2] is 2", Q([1,2,3,2]).FindFirst(2), 2)
    Then("FindLast(2) in [1,2,3,2] is 4", Q([1,2,3,2]).FindLast(2), 4)
    Then("IsEqualTo([1,2],[1,2]) is TRUE", Q([1,2]).IsEqualTo([1,2]), TRUE)
    Then("IsEqualTo([1,2],[1,3]) is FALSE", Q([1,2]).IsEqualTo([1,3]), FALSE)
EndScenario()

Scenario("Partition, group and chunk (guards the PartitionW missing-helper fix)")
    Then("GroupBy('@item % 2') on [1..5] groups by parity",
        ListEq(Q([1,2,3,4,5]).GroupBy("@item % 2"), [ [ "1", [1,3,5] ], [ "0", [2,4] ] ]), TRUE)
    Then("PartitionW('@item > 2') on [1..4] -> [[3,4],[1,2]]",
        ListEq(Q([1,2,3,4]).PartitionW("@item > 2"), [ [3,4], [1,2] ]), TRUE)
    Then("Chunks(2) on [1..5] -> [[1,2],[3,4],[5]]",
        ListEq(Q([1,2,3,4,5]).Chunks(2), [ [1,2], [3,4], [5] ]), TRUE)
EndScenario()

Scenario("Splitting (guards the SplitAt engine-arg + SplitToPartsOf mutator fixes)")
    Then("SplitAt(3) on [1..5] -> [[1,2],[3,4,5]]",
        ListEq(Q([1,2,3,4,5]).SplitAt(3), [ [1,2], [3,4,5] ]), TRUE)
    Then("SplittedToPartsOf(2) on [1..5] -> [[1,2],[3,4],[5]]",
        ListEq(Q([1,2,3,4,5]).SplittedToPartsOf(2), [ [1,2], [3,4], [5] ]), TRUE)
    Given("a list mutated in place by SplitToPartsOf")
    o3 = Q([1,2,3,4,5])
    o3.SplitToPartsOf(2)
    Then("SplitToPartsOf(2) mutates -> [[1,2],[3,4],[5]]",
        ListEq(o3.Content(), [ [1,2], [3,4], [5] ]), TRUE)
EndScenario()

Scenario("Structure ops: rotate, swap, take, remove-first")
    Then("RotatedLeft(1) [1,2,3,4] -> [2,3,4,1]", ListEq(Q([1,2,3,4]).RotatedLeft(1), [ 2,3,4,1 ]), TRUE)
    Then("RotatedRight(1) [1,2,3,4] -> [4,1,2,3]", ListEq(Q([1,2,3,4]).RotatedRight(1), [ 4,1,2,3 ]), TRUE)
    Then("TakeLast(2) [1..5] -> [4,5]", ListEq(Q([1,2,3,4,5]).TakeLast(2), [ 4, 5 ]), TRUE)
    Given("lists mutated in place")
    os = Q([1,2,3,4])  os.Swap(1,4)
    Then("Swap(1,4) [1,2,3,4] -> [4,2,3,1]", ListEq(os.Content(), [ 4,2,3,1 ]), TRUE)
    orf = Q([1,2,3])  orf.RemoveFirstItem()
    Then("RemoveFirstItem [1,2,3] -> [2,3]", ListEq(orf.Content(), [ 2, 3 ]), TRUE)
EndScenario()

Scenario("Type checks and item equality")
    Then("IsListOfNumbers([1,2,3]) is TRUE", Q([1,2,3]).IsListOfNumbers(), TRUE)
    Then("IsListOfStrings([a,b]) is TRUE", Q([ "a","b" ]).IsListOfStrings(), TRUE)
    Then("AllItemsAreEqual([5,5,5]) is TRUE", Q([5,5,5]).AllItemsAreEqual(), TRUE)
    Then("AllItemsAreEqual([5,6]) is FALSE", Q([5,6]).AllItemsAreEqual(), FALSE)
EndScenario()

Scenario("Zip, interleave and pairs")
    Then("ZippedWith([1,2,3],[a,b,c]) -> [[1,a],[2,b],[3,c]]",
        ListEq(Q([1,2,3]).ZippedWith([ "a","b","c" ]), [ [1,"a"], [2,"b"], [3,"c"] ]), TRUE)
    Then("InterleavedWith([1,2,3],[a,b,c]) -> [1,a,2,b,3,c]",
        ListEq(Q([1,2,3]).InterleavedWith([ "a","b","c" ]), [ 1,"a",2,"b",3,"c" ]), TRUE)
    Then("Pairs([1,2,3,4]) -> [[1,2],[2,3],[3,4]]",
        ListEq(Q([1,2,3,4]).Pairs(), [ [1,2], [2,3], [3,4] ]), TRUE)
EndScenario()

Scenario("Reduce / accumulate (guards the cross-DLL reduce-value fix)")
    Then("Reduce() of [1,2,3,4] is 10 (numeric sum)", Q([1,2,3,4]).Reduce(), 10)
    Then("ReduceXT('@accumulator + @item', 0) on [1..4] is 10", Q([1,2,3,4]).ReduceXT("@accumulator + @item", 0), 10)
    Then("ReduceXT with init 100 is 110", Q([1,2,3,4]).ReduceXT("@accumulator + @item", 100), 110)
    Then("ReduceNoInit('@accumulator * @item') on [1..4] is 24", Q([1,2,3,4]).ReduceNoInit("@accumulator * @item"), 24)
EndScenario()

Scenario("Append, pop and prepend-with")
    Given("a list grown then popped")
    oa = Q([1,2,3])
    oa.Append(4)
    Then("Append(4) -> [1,2,3,4]", ListEq(oa.Content(), [ 1,2,3,4 ]), TRUE)
    op = Q([1,2,3])
    nTop = op.Pop()
    Then("Pop returns the last item (3)", nTop, 3)
    Then("Pop leaves [1,2]", ListEq(op.Content(), [ 1, 2 ]), TRUE)
    Then("PrependedWith([3,4],[1,2]) -> [1,2,3,4]", ListEq(Q([3,4]).PrependedWith([1,2]), [ 1,2,3,4 ]), TRUE)
EndScenario()

Scenario("Probabilistic quantifiers")
    Given("the deterministic quantifiers")
    Then("All([A,B,C]) returns all", ListEq(All([ "A","B","C" ]), [ "A", "B", "C" ]), TRUE)
    Then("No([A,B,C]) returns []", ListEq(No([ "A","B","C" ]), [ ]), TRUE)
    Then("AllOf is an alias of All", ListEq(AllOf([ "A","B","C" ]), [ "A", "B", "C" ]), TRUE)
    Then("NoOneOf is an alias of No", ListEq(NoOneOf([ "A","B","C" ]), [ ]), TRUE)

    Given("a 10-item list and the proportional quantifiers (counts are stable; selection is random)")
    aTen = [ 1,2,3,4,5,6,7,8,9,10 ]
    Then("Few -> 2 items", len(Few(aTen)), 2)
    Then("Some -> 3 items", len(Some(aTen)), 3)
    Then("Half -> 5 items", len(Half(aTen)), 5)
    Then("Most -> 9 items", len(Most(aTen)), 9)
    Then("Few < Some < Most (the continuum holds)", (len(Few(aTen)) < len(Some(aTen))) and (len(Some(aTen)) < len(Most(aTen))), TRUE)
    When("Some(aTen) is sampled")
    aSample = Some(aTen)
    bAllIn = TRUE
    for x in aSample if ring_find(aTen, x) = 0 bAllIn = FALSE ok next
    Then("every sampled item belongs to the source", bAllIn, TRUE)
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
