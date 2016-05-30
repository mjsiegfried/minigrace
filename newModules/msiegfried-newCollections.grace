import "collectionsPrelude" as cp

class bag<T> {

    method asString { "a bag factory" }

    method withAll(a: Iterable<T>) {
        def result = self.empty 
        a.do { elt -> result.add(elt) }
        result
    }

    class empty {
        inherits cp.collection.TRAIT
        var size is readable := 0
        var inner := emptyDictionary

        method contains(elt) {
            return inner.containsKey(elt) 
        }

        method add(elt:T) {
            var numElts := 0
            if(inner.containsKey(elt)) then {
                numElts := inner.at(elt)
            }
            inner.at(elt) put (numElts + 1)
            size := size + 1 
            self    // for chaining
        }

        method addAll(elements) {
            for (elements) do { elt ->
                self.add(elt) 
            }
            self    // for chaining
        }

        method remove (elt:T) ifAbsent (block) {
            if (inner.containsKey(elt)) then {
                var newNumElts := (inner.at(elt) - 1)
                if ((newNumElts) < 1) then {
                    inner.removeKey(elt)
                }
                else {
                    inner.at(elt) put (newNumElts)
                }
                size := size - 1
            } else {
                block.apply
            }
            self    // for chaining
        }

        method remove(elt:T) {
            remove (elt) ifAbsent {
                NoSuchObject.raise "set does not contain {elt}"
            }
            self    // for chaining
        }

        method removeAll (elt:T) ifAbsent (block) {
            if (inner.containsKey(elt)) then {
                var numElts := (inner.at(elt))
                inner.removeKey(elt)
                size := size - numElts
            } else {
                block.apply
            }
            self    // for chaining
        }

        method removeAll(elt:T) {
            removeAll (elt) ifAbsent {
                NoSuchObject.raise "set does not contain {elt}"
            }
            self    // for chaining
        }

        method asString {
            var s := "bag\["
            do {each -> s := s ++ each.asString }
                separatedBy { s := s ++ ", " }
            s ++ "\]"
        }

        method do(block1) {
            inner.keysAndValuesDo { k, v -> 
                for (0..(v-1)) do {   
                    block1.apply(k)
                }
            } 
        }

        method includes(booleanBlock) {
            self.do { each ->
                if (booleanBlock.apply(each)) then { return true }
            }
            return false
        }
        method find(booleanBlock)ifNone(notFoundBlock) {
            self.do { each ->
                if (booleanBlock.apply(each)) then { return each }
            }
            return notFoundBlock.apply
        }

        method countOf(elt:T) {
            if (inner.containsKey(elt)) then {
                return inner.at(elt)        
            }
            else {
                return 0
            }
        }

        class iterator {
            var source := emptyList
            outer.do { k ->
                source.add(k) 
            }
            def sourceIterator = source.iterator
            method hasNext { sourceIterator.hasNext }
            method next { sourceIterator.next }
        }

        method ==(other) {
            if (Iterable.match(other)) then {
                var otherSize := 0
                other.do { each ->
                    otherSize := otherSize + 1
                    if (! self.contains(each)) then {
                        return false
                    }
                }
                otherSize == self.size
            } else { 
                false
            }
        }

        method copy {
            outer.withAll(self)
        }

        method ++ (other) {
        // bag union
            copy.addAll(other)
        }

        method -- (other) {
        // bag difference
            def result = bag.empty
            for (self) do {v->
                if (!other.contains(v)) then {
                    result.add(v)
                }
            }
            result
        }
        method ** (other) {
        // bag intersection
            (filter {each -> other.contains(each)})
        }

        method isSubset(s2: Iterable<T>) {
            self.do{ each ->
                if (s2.contains(each).not) then { return false }
            }
            return true
        }

        method isSuperset(s2: Iterable<T>) {
            s2.do{ each ->
                if (self.contains(each).not) then { return false }
            }
            return true
        }
        method into(existing: Expandable<T>) -> Collection<T> {
            do { each -> existing.add(each) }
            existing
        }

        class elementsAndCounts -> Enumerable<T> {
            inherits cp.enumerable.TRAIT<T>
            method do(block1) {
                inner.keysAndValuesDo (block1) 
            }

            method iterator {
                inner.bindingsIterator
            }

            method asList {
                var result := emptyList 
                for (self) do { k, v -> result.add(k::v) }
                result
            }
        }         
    }
}



