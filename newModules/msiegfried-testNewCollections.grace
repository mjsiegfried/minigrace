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

        method testDictionarySizeAfterRemove {
            oneToFive.remove(1)
            deny(oneToFive.contains(1)) description "1 still present"
            assert(oneToFive.size) shouldBe 4 
        }

        method testDictionarySizeAfterRemoveAll {
            acesAndEights.removeAll(1)
            deny(acesAndEights.contains(1)) description "1 still present"
            assert(acesAndEights.size) shouldBe 3 
        }

        method testDictionaryContentsAfterMultipleRemove {
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

        method testDictionaryEmptyDo {
            empty.do {each -> failBecause "emptySet.do did with {each}"}
            assert (true)   // so that there is always an assert
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
    
    }

}

def bagTests = gU.testSuite.fromTestMethodsIn(bagTest)
bagTests.runAndPrintResults


