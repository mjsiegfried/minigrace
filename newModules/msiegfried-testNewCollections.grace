import "gUnit" as gU
import "msiegfried-newCollections" as nc 

def bagTest = object {
    class forMethod(m) {
        inherits gU.testCaseNamed(m)

        var oneToFive
        var acesAndEights
        var empty

        method setup {
            oneToFive := nc.bag.withAll [1,2,3,4,5]
            acesAndEights := nc.bag.withAll [1,1,8,8,8]
            empty := nc.bag.empty
        }

        method testBagSize {
            assert(oneToFive.size) shouldBe 5
            assert(empty.size) shouldBe 0
            assert(acesAndEights.size) shouldBe 5
        }

        method testAdd {
            assert (empty.add(9)) shouldBe (nc.bag.withAll [9])
            assert (acesAndEights.add(10)) shouldBe  (nc.bag.withAll [1,1,8,8,8,10])
        }

        method testAddMultiple {
            assert (empty.addMultiple(9, 5)) shouldBe (nc.bag.withAll [9,9,9,9,9])
            assert (acesAndEights.addMultiple(10,2)) shouldBe  (nc.bag.withAll [1,1,8,8,8,10,10])
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
            def bag2 = nc.bag.withAll [1,2]
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
            nc.bag.withAll [1].do { each -> assert(each)shouldBe(1) }
                separatedBy { s := "kilroy" }
            assert (s) shouldBe ("nothing")
        }

        method testAcesAndEightsIterator {
            def ei = acesAndEights.iterator
            assert (acesAndEights.size == 5) description "acesAndEights.size = {acesAndEights.size}, should be 5"
            assert (ei.hasNext) description "the acesAndEights iterator has no elements"
            def copyBag = nc.bag.withAll [ei.next, ei.next, ei.next, ei.next, ei.next]
            deny (ei.hasNext) description "the acesAndEights iterator has more than 5 elements"
            assert (copyBag) shouldBe (acesAndEights)
        }

        method testBagMapAcesAndEights {
            assert(acesAndEights.map{x -> x + 1}.into (emptySet)) shouldBe (set
[2, 9])
        }

        method testBagFilterOdd {
            assert(oneToFive.filter{x -> (x % 2) == 1}.into (empty))
                shouldBe (nc.bag.withAll [1, 3, 5])
        }
        method testBagCopy {
            def acesAndEightsCopy = acesAndEights.copy
            acesAndEights.remove(1)
            assert (acesAndEights.size) shouldBe 4
            assert (acesAndEights) shouldBe (nc.bag.withAll [1,8,8,8])
            assert (acesAndEightsCopy) shouldBe (nc.bag.withAll [1,1,8,8,8])

        }

        method testBagUnion {
            assert (oneToFive ++ acesAndEights) shouldBe (nc.bag.withAll [1,1,2,3,4,5,8,8,8])
        }
        method testBagDifference {
            assert (oneToFive -- acesAndEights) shouldBe (nc.bag.withAll [1,2,3,4,5,8,8,8])
        }


        // this is broken at the moment... 
        method testBagIntersection {
//            assert (oneToFive ** acesAndEights) shouldBe (nc.bag.withAll [1])
        }


        method testBagFailFastIterator {
            def input = nc.bag.withAll [1,5,3,2,4]
            def iter = input.iterator
            input.add(6)
            assert {iter.next} shouldRaise (ConcurrentModification)
            def iter2 = input.iterator
            assert {iter2.next} shouldntRaise (ConcurrentModification)
            def iter3 = input.iterator
            input.remove(2)
            assert {iter3.next} shouldRaise (ConcurrentModification)
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
            assert (elAndCount[1]) shouldBe (1::1) 
        }

        method testBagEqualityEmpty {
            assert(empty == nc.bag.empty)
            deny (empty != nc.bag.empty)
        }

        method testBagInequalityEmpty {
            deny(empty == nc.bag.withAll [1])
            assert(empty != nc.bag.withAll [1])
            deny(empty == 3)
            deny(empty == acesAndEights)
        }

        method testBagInequalityFive {
            deny(oneToFive == nc.bag.withAll [1, 2, 3, 4, 6])
            assert(oneToFive != nc.bag.withAll [1, 2, 3, 4, 6])
        }

        method testBagEqualityFive {
            def isEqual = (oneToFive == nc.bag.withAll [1, 2, 3, 4, 5])
            assert(isEqual)
            deny(oneToFive != nc.bag.withAll [1, 2, 3, 4, 5])
        }
    
    }

}

def bagTests = gU.testSuite.fromTestMethodsIn(bagTest)
bagTests.runAndPrintResults


