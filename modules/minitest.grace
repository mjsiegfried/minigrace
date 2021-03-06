import "gUnit" as gu

inherits prelude.methods

def nullSuite = _prelude.Singleton.named "nullSuite"
def nullBlock = _prelude.Singleton.named "nullBlock"

var currentTestSuiteForDialect := nullSuite
var currentSetupBlockForTesting := nullBlock
var currentTestBlockForTesting := 0
var currentTestInThisEvaluation := 0

method numberOfErrorsToRerun -> Number { gu.numberOfErrorsToRerun }
method numberOfErrorsToRerun:=(n:Number) {
    gu.numberOfErrorsToRerun := n
}

def mtAssertion = object {
    inherits gu.assertion
    var currentResult is writable := object {
        method countOneAssertion {
            print "countOneAssertion requested on dummy result"
        }
    }

    method countOneAssertion {
        currentResult.countOneAssertion
    }
}

method assert(bb:Boolean) description(str:String) {
    mtAssertion.assert(bb) description(str)
}

method deny(bb:Boolean) description(str:String) {
    mtAssertion.deny(bb) description(str)
}

method assert(bb:Boolean) {
    mtAssertion.assert(bb)
}

method deny(bb:Boolean) {
    mtAssertion.deny(bb)
}

method assert(s1:Object) shouldBe (s2:Object) {
    mtAssertion.assert(s1) shouldBe (s2)
}

method assert(s1:Object) shouldntBe (s2:Object) {
    mtAssertion.assert(s1) shouldntBe (s2)
}

method assert(n1:Number) shouldEqual (n2:Number) within (epsilon:Number) {
    mtAssertion.assert(n1) shouldEqual (n2) within (epsilon)
}

method assert(b:Block) shouldRaise (desired:ExceptionKind) {
    mtAssertion.assert(b) shouldRaise (desired)
}

method assert(b:Block) shouldntRaise (undesired:ExceptionKind) {
    mtAssertion.assert(b) shouldntRaise (undesired)
}

method assert(s:Object) hasType (desired:Type) {
    mtAssertion.assert(s) hasType (desired)
}

method deny(s:Object) hasType (undesired:Type) {
    mtAssertion.deny(s) hasType (undesired)
}

method assertType(T:Type) describes (value) {
    mtAssertion.assertType(T) describes (value)
}

method failBecause(reason) {
    mtAssertion.assert(false) description(reason)
}

method testSuiteNamed (name:String) with (block:Block) {
    if(currentTestSuiteForDialect != nullSuite) then {
        Exception.raise("a testSuite cannot be created inside a testSuite")
    }
    currentTestSuiteForDialect := gu.testSuite.empty
    currentTestSuiteForDialect.name := name
    currentSetupBlockForTesting := block
    currentTestInThisEvaluation := 0
    block.apply()
    currentSetupBlockForTesting := nullBlock
    currentTestSuiteForDialect.runAndPrintResults()
    currentTestSuiteForDialect := nullSuite
    currentTestBlockForTesting := 0
}

method testSuite (block:Block) {
    testSuiteNamed "" with (block)
}

method test(name:String) by(block:Block) {
    if(currentTestSuiteForDialect == nullSuite) then {
        Exception.raise("a test can be created only within a testSuite")
    }
    currentTestInThisEvaluation := currentTestInThisEvaluation + 1
    if (currentSetupBlockForTesting != nullBlock) then {
        currentTestSuiteForDialect.add(testCaseNamed(name)
            setupIn(currentSetupBlockForTesting)
            asTestNumber(currentTestInThisEvaluation))
    } elseif { currentTestInThisEvaluation == currentTestBlockForTesting } then {
            block.apply()
    }
}

method testCaseNamed(name') setupIn(setupBlock) asTestNumber(number) -> gu.TestCase {
    object {
        inherits gu.testCaseNamed(name')

        method setup { 
            super.setup
            currentTestBlockForTesting := number
            currentTestInThisEvaluation := 0
            setupBlock.apply
        }

        method teardown {
            currentTestBlockForTesting := 0
        }
        
        method currentResult:= (r) is override {
            mtAssertion.currentResult := r
        }
        
        method runTest is override {
            // for minitest, the test is run in setup
        }
    }
}

