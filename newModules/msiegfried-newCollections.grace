class bag<T> {

    method asString { "a bag factory" }

    method withAll(a: Iterable<T>) {
        def result = self.empty 
        a.do { x -> result.add(x) }
        result
    }

    class empty {
        inherits collection.TRAIT
        var size is readable := 0
        var inner := emptyDictionary

        method contains(x) {
            return inner.containsKey(x) 
        }

        method add(x:T) {
            var numXs := 0
            if(inner.containsKey(x)) then {
                numXs := inner.at(x)
            }
            inner.at(x) put (numXs + 1)
            size := size + 1 
            self    // for chaining
        }

        method addAll(elements) {
            for (elements) do { x ->
                self.add(x) 
            }
            self    // for chaining
        }

        method remove (elt:T) ifAbsent (block) {
            if (inner.containsKey(elt)) then {
                inner.removeKey(elt)
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

        method do(block1) separatedBy(block0) {
            var firstTime := true
            var i := 0
            self.do { each ->
                if (firstTime) then {
                    firstTime := false
                } else {
                    block0.apply
                }
                block1.apply(each)
            }
            return self
        }

        method iterator {
            object {
                var count := 1
                var idx := -1
                method hasNext { size >= count }
                method next {
                    var candidate
                    def innerSize = inner.size
                    while {
                        idx := idx + 1
                        if (idx >= innerSize) then {
                            IteratorExhausted.raise "iterator over {outer.asString}"
                        }
                        candidate := inner.at(idx)
                    } do { }
                    count := count + 1
                    candidate
                }
            }
        }







    }

}



