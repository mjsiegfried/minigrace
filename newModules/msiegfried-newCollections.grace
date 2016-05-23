class bag<T> {

    method asString { "a bag factory" }

    method withAll(a: Iterable<T>) {
        def result = self.empty 
        a.do { x -> result.add(x) }
        result
    }

    class empty {
        inherits collection.TRAIT<T>
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
            var s := "bag\{"
            do {each -> s := s ++ each.asString }
                separatedBy { s := s ++ ", " }
            s ++ "\}"
        }

        method do(block1) {
            inner.keysAndValuesDo { k, v -> {
                for (0..v) {   
                    block1.apply(k)
                }
            } 
        }

        method isSubset(b2: Bag<T>) {
            self.do{ each ->
                if (b2.contains(each).not) then { return false }
            }
            return true
        }

        method isSuperset(b2: Iterable<T>) {
            b2.do{ each ->
                if (self.contains(each).not) then { return false }
            }
            return true
        }



    }

}



