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
                var numElts := (inner.at(elt) - 1)
                if ((numElts) < 1) then {
                    inner.removeKey(elt)
                }
                else {
                    inner.at(elt) put (numElts)
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

        method countOf(elt:T) {
            if (inner.containsKey(elt)) then {
                return inner.at(elt)        
            }
            else {
                return 0
            }
        }

        method elementsAndCounts -> Enumerable<T> {
            object {
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
}



