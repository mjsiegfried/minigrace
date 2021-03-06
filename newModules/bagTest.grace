import "gUnit" as gU
import "bag" as bc 

def bagTest = object {
    class forMethod(m) {
        inherits gU.testCaseNamed(m)

        var oneToFive
        var acesAndEights
        var empty

        method setup {
            oneToFive := bc.bag.withAll [1,2,3,4,5]
            acesAndEights := bc.bag.withAll [1,1,8,8,8]
            empty := bc.bag.empty
        }

        method testBagSize {
            assert(oneToFive.size) shouldBe 5
            assert(empty.size) shouldBe 0
            assert(acesAndEights.size) shouldBe 5
        }

        method testAdd {
            assert (empty.add(9)) shouldBe (bc.bag.withAll [9])
            assert (acesAndEights.add(10)) shouldBe  (bc.bag.withAll [1,1,8,8,8,10])
        }

        method testAddMultiple {
            assert (empty.addMultiple(9, 5)) shouldBe (bc.bag.withAll [9,9,9,9,9])
            assert (acesAndEights.addMultiple(10,2)) shouldBe  (bc.bag.withAll [1,1,8,8,8,10,10])
        }

        method testBagSizeAfterRemove {
            oneToFive.remove(1)
            deny(oneToFive.contains(1)) description "1 still present"
            assert(oneToFive.size) shouldBe 4 
        }

        method testBagSizeAfterRemoveAll {
            acesAndEights.removeAll(1)
            deny(acesAndEights.contains(1)) description "1 still present"
            assert(acesAndEights.size) shouldBe 3 
        }

        method testBagContentsAfterMultipleRemove {
            oneToFive.remove(1).remove(2).remove(3)
            assert(oneToFive.size) shouldBe 2
            deny(oneToFive.contains(1)) description "1 still present"
            deny(oneToFive.contains (2)) description "2 still present"
            deny(oneToFive.contains (3)) description "3 still present"
            assert(oneToFive.contains(4))
            assert(oneToFive.contains(5))
        }

        method testAsString {
            def bag2 = bc.bag.withAll [1,2]
            def bStr = bag2.asString
            assert((bStr == "bag[1, 2]") || {bStr == "bag[2, 1]"})
                description "\"{bStr}\" should be \"bag[1, 2]\""
        }

        method testAsStringEmpty {
            assert(empty.asString) shouldBe "bag[]"
        }

        method testBagEmptyDo {
            empty.do {each -> failBecause "emptyBag.do did with {each}"}
            assert (true)   // so that there is always an assert
        }

        method testBagOneToFiveDo {
            def accum = empty
            var n := 1
            oneToFive.do { each ->
                accum.add(each)
                assert (accum.size) shouldBe (n)
                n := n + 1
            }
            assert(accum) shouldBe (oneToFive)
        }

        method testAcesAndEightsDo {
            def accum = empty
            var n := 1
            acesAndEights.do { each ->
                accum.add(each)
                assert (accum.size) shouldBe (n)
                n := n + 1
            }
            assert(accum) shouldBe (acesAndEights)
        }

        method testBagDoSeparatedBy {
            var s := ""
            acesAndEights.remove(1).remove(1)
            acesAndEights.do { each -> s := s ++ each.asString } separatedBy { s := s ++ ", " }
            assert (s == "8, 8, 8")
                description "{s} should be \"8, 8, 8\""
        }

        method testBagDoSeparatedByEmpty {
            var s := "nothing"
            empty.do { failBecause "do did when list is empty" }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testBagDoSeparatedBySingleton {
            var s := "nothing"
            bc.bag.withAll [1].do { each -> assert(each)shouldBe(1) }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testAcesAndEightsIterator {
            def ei = acesAndEights.iterator
            assert (acesAndEights.size == 5) description "acesAndEights.size = {acesAndEights.size}, should be 5"
            assert (ei.hasNext) description "the acesAndEights iterator has no elements"
            def copyBag = bc.bag.withAll [ei.next, ei.next, ei.next, ei.next, ei.next]
            deny (ei.hasNext) description "the acesAndEights iterator has more than 5 elements"
            assert (copyBag) shouldBe (acesAndEights)
        }

        method testBagMapAcesAndEights {
            assert(acesAndEights.map{x -> x + 1}.into (emptySet)) shouldBe (set
[2, 9])
        }

        method testBagFilterOdd {
            assert(oneToFive.filter{x -> (x % 2) == 1}.into (empty))
                shouldBe (bc.bag.withAll [1, 3, 5])
        }
        method testBagCopy {
            def acesAndEightsCopy = acesAndEights.copy
            acesAndEights.remove(1)
            assert (acesAndEights.size) shouldBe 4
            assert (acesAndEights) shouldBe (bc.bag.withAll [1,8,8,8])
            assert (acesAndEightsCopy) shouldBe (bc.bag.withAll [1,1,8,8,8])

        }

        method testBagUnion {
            assert (oneToFive ++ acesAndEights) shouldBe (bc.bag.withAll [1,1,2,3,4,5,8,8,8])
        }
        method testBagDifferebce {
            assert (oneToFive -- acesAndEights) shouldBe (bc.bag.withAll [2,3,4,5])
        }

        method testBagIntersection {
            assert (oneToFive ** acesAndEights) shouldBe (bc.bag.withAll [1])
        }

        method testCountOf {
            assert (acesAndEights.countOf(8)) shouldBe 3
            assert (empty.countOf(8)) shouldBe 0
        }

        method testElementsAndCounts {
            var elAndCount := oneToFive.elementsAndCounts
            var elAndCount2 := acesAndEights.elementsAndCounts
            assert (elAndCount) hasType (Enumerable<Binding<Number,Number>>)
            assert(elAndCount.into (emptySet)) shouldBe (
                set [1::1, 2::1, 3::1, 4::1, 5::1])
            assert(elAndCount2.into (emptySet)) shouldBe (
                set [1::2, 8::3])
        }

        method testElementsAndCountsAsList {
            var elAndCount := oneToFive.elementsAndCounts.asList
            assert (elAndCount) hasType (List<Binding<Number,Number>>)
            assert (elAndCount.size) shouldBe 5
            assert (elAndCount [1]) shouldBe (1::1) 
        }

        method testBagEqualityEmpty {
            assert(empty == bc.bag.empty)
            deny (empty != bc.bag.empty)
        }

        method testBagInequalityEmpty {
            deny(empty == bc.bag.withAll [1])
            assert(empty != bc.bag.withAll [1])
            deny(empty == 3)
            deny(empty == acesAndEights)
        }

        method testBagInequalityFive {
            deny(oneToFive == bc.bag.withAll [1, 2, 3, 4, 6])
            assert(oneToFive != bc.bag.withAll [1, 2, 3, 4, 6])
        }

        method testBagEqualityFive {
            def isEqual = (oneToFive == bc.bag.withAll [1, 2, 3, 4, 5])
            assert(isEqual)
            deny(oneToFive != bc.bag.withAll [1, 2, 3, 4, 5])
        }
    
    }

}


def twoWayTest = object {
    class forMethod(m) {
        inherits gU.testCaseNamed(m)

        var oneToFive
        var evens
        var empty

        method setup {
            oneToFive := bc.dictionary.withAll ["one"::1, "two"::2, "three"::3, "four"::4, "five"::5]
            evens := bc.dictionary.ithAll ["two"::2, "four"::4, "six"::6, "eight"::8]
            empty := bc.dictionary.empty 

            //oneToFive := tw.twoWayDictionary.withAll ["one"::1, "two"::2, "three"::3, "four"::4, "five"::5]
            //evens := tw.twoWayDictionary.withAll ["two"::2, "four"::4, "six"::6, "eight"::8]
            //empty := tw.twoWayDictionary.empty 
        }
        method testDictionaryTypeCollection {
            assert (oneToFive) hasType (Collection<Binding<String,Number>>)
        }
        method testDictionaryTypeDictionary {
            assert (oneToFive) hasType (Dictionary<String,Number>)
        }
        method testDictionaryTypeNotTypeWithWombat {
            deny (oneToFive) hasType (Dictionary<String,Number> & type { wombat })
        }

        method testDictionarySize {
            assert(oneToFive.size) shouldBe 5
            assert(empty.size) shouldBe 0
            assert(evens.size) shouldBe 4
        }

        method testDictionarySizeAfterRemove {
            oneToFive.removeKey "one"
            deny(oneToFive.containsKey "one") description "\"one\" still present"
            oneToFive.removeKey "two"
            oneToFive.removeKey "three"
            assert(oneToFive.size) shouldBe 2
        }

        method testDictionaryContentsAfterMultipleRemove {
            oneToFive.removeKey "one" .removeKey "two" .removeKey "three"
            assert(oneToFive.size) shouldBe 2
            deny(oneToFive.containsKey "one") description "\"one\" still present"
            deny(oneToFive.containsKey "two") description "\"two\" still present"
            deny(oneToFive.containsKey "three") description "\"three\" still present"
            assert(oneToFive.containsKey "four")
            assert(oneToFive.containsKey "five")
        }

        method testAsString {
            def dict2 = dictionary ["one"::1, "two"::2]
            def dStr = dict2.asString
            assert((dStr == "dict⟬one::1, two::2⟭") || {dStr == "dict⟬two::2, one::1⟭"})
                description "\"{dStr}\" should be \"dict⟬one::1, two::2⟭\""
        }

        method testAsStringEmpty {
            assert(empty.asString) shouldBe "dict⟬⟭"
        }

        method testDictionaryEmptyDo {
            empty.do {each -> failBecause "emptySet.do did with {each}"}
            assert (true)   // so that there is always an assert
        }

        method testDictionaryEqualityEmpty {
            assert(empty == emptyDictionary)
            deny(empty != emptyDictionary)
        }
        method testDictionaryInequalityEmpty {
            deny(empty == dictionary ["one"::1])
                description "empty dictionary equals dictionary with \"one\"::1"
            assert(empty != dictionary ["two"::2])
                description "empty dictionary equals dictionary with \"two\"::2"
            deny(empty == 3)
            deny(empty == evens)
        }
        method testDictionaryInequalityFive {
            evens.at "ten" put 10
            assert(evens.size == oneToFive.size) description "evens.size should be 5"
            deny(oneToFive == evens)
            assert(oneToFive != evens)
        }
        method testDictionaryEqualityFive {
            assert(oneToFive == dictionary ["one"::1, "two"::2, "three"::3,
                "four"::4, "five"::5])
        }
        method testDictionaryKeysAndValuesDo {
            def accum = emptyDictionary
            var n := 1
            oneToFive.keysAndValuesDo { k, v ->
                accum.at(k)put(v)
                assert (accum.size) shouldBe (n)
                n := n + 1
            }
            assert(accum) shouldBe (oneToFive)
        }
        method testDictionaryEmptyBindingsIterator {
            deny (empty.bindings.iterator.hasNext)
                description "the empty bindings iterator has elements"
        }
        method testDictionaryEvensBindingsIterator {
            def ei = evens.bindings.iterator
            assert (evens.size == 4) description "evens doesn't contain 4 elements!"
            assert (ei.hasNext) description "the evens iterator has no elements"
            def copyDict = dictionary [ei.next, ei.next, ei.next, ei.next]
            deny (ei.hasNext) description "the evens iterator has more than 4 elements"
            assert (copyDict) shouldBe (evens)
        }
        method testDictionaryAdd {
            assert (empty.at "nine" put(9))
                shouldBe (dictionary ["nine"::9])
            assert (evens.at "ten" put(10).values.into (emptySet))
                shouldBe (set [2, 4, 6, 8, 10])
        }
        method testDictionaryRemoveKeyTwo {
            assert (evens.removeKey "two".values.into (emptySet)) shouldBe (set [4, 6, 8])
            assert (evens.values.into (emptySet)) shouldBe (set [4, 6, 8])
        }
        method testDictionaryRemoveValue4 {
            assert (evens.size == 4) description "evens doesn't contain 4 elements"
            assert (evens.size == 4) description "initial size of evens isn't 4"
            evens.removeValue 4
            assert (evens.size == 3)
                description "after removing 4, 3 elements should remain in evens"
            assert (evens.containsKey "two") description "Can't find key \"two\""
            assert (evens.containsKey "six") description "Can't find key \"six\""
            assert (evens.containsKey "eight") description "Can't find key \"eight\""
            deny (evens.containsKey "four") description "Found key \"four\""
            assert (evens.removeValue 4 ifAbsent { }.values.into (emptySet)) shouldBe (set [2, 6, 8])
            assert (evens.values.into (emptySet)) shouldBe (set [2, 6, 8])
            assert (evens.keys.into (emptySet)) shouldBe (set ["two", "six", "eight"])
        }
        method testDictionaryRemoveMultiple {
            evens.removeValue 4 .removeValue 6 .removeValue 8
            assert (evens) shouldBe (emptyDictionary.at "two" put 2)
        }
        method testDictionaryRemove5 {
            assert {evens.removeKey 5} shouldRaise (NoSuchObject)
        }
        method testDictionaryRemoveKeyFive {
            assert {evens.removeKey "Five"} shouldRaise (NoSuchObject)
        }
        method testDictionaryChaining {
            oneToFive.at "eleven" put(11).at "twelve" put(12).at "thirteen" put(13)
            assert (oneToFive.values.into (emptySet)) shouldBe (set [1, 2, 3, 4, 5, 11, 12, 13])
        }
        method testDictionaryPushAndExpand {
            evens.removeKey "two"
            evens.removeKey "four"
            evens.removeKey "six"
            evens.at "ten" put(10)
            evens.at "twelve" put(12)
            evens.at "fourteen" put(14)
            evens.at "sixteen" put(16)
            evens.at "eighteen" put(18)
            evens.at "twenty" put(20)
            assert (evens.values.into (emptySet))
                shouldBe (set [8, 10, 12, 14, 16, 18, 20])
        }

        method testDictionaryFold {
            assert(oneToFive.fold{a, each -> a + each}startingWith(5))shouldBe(20)
            assert(evens.fold{a, each -> a + each}startingWith(0))shouldBe(20)
            assert(empty.fold{a, each -> a + each}startingWith(17))shouldBe(17)
        }

        method testDictionaryDoSeparatedBy {
            var s := ""
            evens.removeValue 2 .removeValue 4
            evens.do { each -> s := s ++ each.asString } separatedBy { s := s ++ ", " }
            assert ((s == "6, 8") || (s == "8, 6"))
                description "{s} should be \"8, 6\" or \"6, 8\""
        }

        method testDictionaryDoSeparatedByEmpty {
            var s := "nothing"
            empty.do { failBecause "do did when list is empty" }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testDictionaryDoSeparatedBySingleton {
            var s := "nothing"
            set [1].do { each -> assert(each)shouldBe(1) }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testDictionaryAsStringNonEmpty {
            evens.removeValue(6)
            evens.removeValue(8)
            assert ((evens.asString == "dict⟬two::2, four::4⟭") ||
                        (evens.asString == "dict⟬four::4, two::2⟭"))
                        description "evens.asString = {evens.asString}"
        }

        method testDictionaryAsStringEmpty {
            assert (empty.asString) shouldBe ("dict⟬⟭")
        }

        method testDictionaryMapEmpty {
            assert (empty.map{x -> x * x}.into (emptySet)) shouldBe (emptySet)
        }

        method testDictionaryMapEvens {
            assert(evens.map{x -> x + 1}.into (emptySet)) shouldBe (set [3, 5, 7, 9])
        }

        method testDictionaryMapEvensInto {
            assert(evens.map{x -> x + 10}.into(set(evens)))
                shouldBe (set [2, 4, 6, 8, 12, 14, 16, 18])
        }

        method testDictionaryFilterNone {
            assert(oneToFive.filter{x -> false}.isEmpty)
        }

        method testDictionaryFilterEmpty {
            assert(empty.filter{x -> (x % 2) == 1}.isEmpty)
        }

        method testDictionaryFilterOdd {
            assert(oneToFive.filter{x -> (x % 2) == 1}.into (emptySet))
                shouldBe (set [1, 3, 5])
        }

        method testDictionaryMapAndFilter {
            assert(oneToFive.map{x -> x + 10}.filter{x -> (x % 2) == 1}.asSet)
                shouldBe (set [11, 13, 15])
        }
        method testDictionaryBindings {
            assert(oneToFive.bindings.into (emptySet)) shouldBe (
                set ["one"::1, "two"::2, "three"::3, "four"::4, "five"::5])
        }
        method testDictionaryKeys {
            assert(oneToFive.keys.into (emptySet)) shouldBe (
                set ["one", "two", "three", "four", "five"] )
        }
        method testDictionaryValues {
            assert(oneToFive.values.into (emptySet)) shouldBe (
                set [1, 2, 3, 4, 5] )
        }

        method testDictionaryCopy {
            def evensCopy = evens.copy
            evens.removeKey("two")
            evens.removeValue(4)
            assert (evens.size) shouldBe 2
            assert (evensCopy) shouldBe
                (dictionary ["two"::2, "four"::4, "six"::6, "eight"::8])
        }

        method testDictionaryAsDictionary {
            assert(evens.asDictionary) shouldBe (evens)
        }

        method testDictionaryValuesEmpty {
            def vs = empty.values
            assert(vs.isEmpty)
            assert(vs) shouldBe (emptySequence)
        }
        method testDictionaryKeysEmpty {
            assert(empty.keys) shouldBe (emptySequence)
        }
        method testDictionaryValuesSingle {
            assert(dictionary ["one"::1].values) shouldBe
                (sequence [1])
        }
        method testDictionaryKeysSingle {
            assert(dictionary ["one"::1].keys) shouldBe
                (sequence ["one"])
        }
        method testDictionaryBindingsEvens {
            assert(evens.bindings.asSet) shouldBe
                (set ["two"::2, "four"::4, "six"::6, "eight"::8])
        }
        method testDictionarySortedOnValues {
            assert(evens.bindings.sortedBy{b1, b2 -> b1.value.compare(b2.value)})
                shouldBe (sequence ["two"::2, "four"::4, "six"::6, "eight"::8])
        }
        method testDictionarySortedOnKeys {
            assert(evens.bindings.sortedBy{b1, b2 -> b1.key.compare(b2.key)})
                shouldBe (sequence ["eight"::8, "four"::4, "six"::6, "two"::2])
        }


    }
}

def bagTests = gU.testSuite.fromTestMethodsIn(bagTest)
bagTests.runAndPrintResults


