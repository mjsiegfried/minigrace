
def unused = object {
    var unused := true
    def key is public = self
    def value is public = self
    method asString { "unused" }
}

def removed = object {
    var removed := true
    def key is public = self
    def value is public = self
    method asString { "removed" }
}

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
        var numXs := 0

        method add(x:T) {
            if(inner.containsKey(x)) then {
                numXs := inner.at(x)
            }
            inner.at(x) put (numXs + 1)
            size := size + 1 
        }

    }

}



