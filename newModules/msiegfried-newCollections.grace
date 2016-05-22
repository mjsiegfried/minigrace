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

    }

}



