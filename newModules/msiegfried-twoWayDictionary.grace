// copied from newCollections.grace
trait collectionFactory⟦T⟧ {
    method withAll(elts: Iterable⟦T⟧) → Collection⟦T⟧ { abstract }
    method empty → Unknown { withAll [] }
}

type Binding⟦K,T⟧ = {
    key → K
    value → T
    hash → Number
    == → Boolean
}

def binding = object {
    method asString { "binding class" }

    class key(k)value(v) {
        method key {k}
        method value {v}
        method asString { "{k}::{v}" }
        method hashcode { (k.hashcode * 1021) + v.hashcode }
        method hash { (k.hash * 1021) + v.hash }
        method == (other) {
            match (other)
                case {o:Binding → (k == o.key) && (v == o.value) }
                case {_ → return false }
        }
    }
}

class newDictionary⟦K,T⟧ {
    use collectionFactory⟦T⟧

    method asString { "a dictionary factory" }

    method at(k:K)put(v:T) {
            self.empty.at(k)put(v)
    }
    class withAll(initialBindings) → Dictionary⟦K,T⟧ {
        use collection⟦T⟧
        var mods is readable := 0
        var numBindings := 0
        var inner := _prelude.PrimitiveArray.new(8)
        def unused = object {
            var unused := true
            def key is public = self
            def value is public = self
            method asString { "unused" }
            method == (other) {
                match (other)
                    case {o:Binding → (key == o.key) && (value == o.value) }
                    case {_ → return false }
            }
        }
        def removed = object {
            var removed := true
            def key is public = self
            def value is public = self
            method asString { "removed" }
            method == (other) {
                match (other)
                    case {o:Binding → (key == o.key) && (value == o.value) }
                    case {_ → return false }
            }
        }
        for (0..(inner.size-1)) do {i→
            inner.at(i)put(unused)
        }
        for (initialBindings) do { b → at(b.key)put(b.value) }
        method size { numBindings }
        method at(key')put(value') {
            mods := mods + 1
            var t := findPositionForAdd(key')
            if ((inner.at(t) == unused).orElse{inner.at(t) == removed}) then {
                numBindings := numBindings + 1
            }
            inner.at(t)put(binding.key(key')value(value'))
            if ((size * 2) > inner.size) then { expand }
            self    // for chaining
        }
        method at(k) {
            var b := inner.at(findPosition(k))
            if (b.key == k) then {
                return b.value
            }
            NoSuchObject.raise "dictionary does not contain entry with key {k}"
        }
        method at(k) ifAbsent(action) {
            var b := inner.at(findPosition(k))
            if (b.key == k) then {
                return b.value
            }
            action.apply
        }
        method containsKey(k) {
            var t := findPosition(k)
            if (inner.at(t).key == k) then {
                return true
            }
            false
        }
        method removeAllKeys(keys) {
            mods := mods + 1
            for (keys) do { k →
                var t := findPosition(k)
                if (inner.at(t).key == k) then {
                    inner.at(t)put(removed)
                    numBindings := numBindings - 1
                } else {
                    NoSuchObject.raise "dictionary does not contain entry with key {k}"
                }
            }
            self
        }
        method removeKey(k:K) {
            mods := mods + 1
            var t := findPosition(k)
            if (inner.at(t).key == k) then {
                inner.at(t)put(removed)
                numBindings := numBindings - 1
            } else {
                NoSuchObject.raise "dictionary does not contain entry with key {k}"
            }
            self
        }
        method removeAllValues(removals) {
            mods := mods + 1
            for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if (removals.contains(a.value)) then {
                    inner.at(i)put(removed)
                    numBindings := numBindings - 1
                }
            }
            self
        }
        method removeValue(v) {
            // remove all bindings with value v
            mods := mods + 1
            def initialNumBindings = numBindings
            for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if (v == a.value) then {
                    inner.at (i) put (removed)
                    numBindings := numBindings - 1
                }
            }
            if (numBindings == initialNumBindings) then {
                NoSuchObject.raise "dictionary does not contain entry with value {v}"
            }
            self
        }
        method removeValue(v) ifAbsent (action:Block0⟦Unknown⟧) {
            // remove all bindings with value v
            mods := mods + 1
            def initialNumBindings = numBindings
            for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if (v == a.value) then {
                    inner.at (i) put (removed)
                    numBindings := numBindings - 1
                }
            }
            if (numBindings == initialNumBindings) then {
                action.apply
            }
            self
        }
        method containsValue(v) {
            self.valuesDo{ each →
                if (v == each) then { return true }
            }
            false
        }
        method contains(v) { containsValue(v) }

        method findPosition(x) is confidential {
            def h = x.hash
            def s = inner.size
            var t := h % s
            var jump := 5
            while {inner.at(t) != unused} do {
                if (inner.at(t).key == x) then {
                    return t
                }
                if (jump != 0) then {
                    t := (t * 3 + 1) % s
                    jump := jump - 1
                } else {
                    t := (t + 1) % s
                }
            }
            return t
        }
        method findPositionForAdd(x) is confidential {
            def h = x.hash
            def s = inner.size
            var t := h % s
            var jump := 5
            while {(inner.at(t) != unused) && {inner.at(t) != removed}} do {
                if (inner.at(t).key == x) then {
                    return t
                }
                if (jump != 0) then {
                    t := (t * 3 + 1) % s
                    jump := jump - 1
                } else {
                    t := (t + 1) % s
                }
            }
            return t
        }
        method asString {
            // do()separatedBy won't work, because it iterates over values,
            // and we need an iterator over bindings.
            var s := "dict⟬"
            var firstElement := true
            for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if ((a != unused) && (a != removed)) then {
                    if (! firstElement) then {
                        s := s ++ ", "
                    } else {
                        firstElement := false
                    }
                    s := s ++ "{a.key}::{a.value}"
                }
            }
            s ++ "⟭"
        }
        method asDebugString {
            var s := "dict⟬"
            for (0..(inner.size-1)) do {i→
                if (i > 0) then { s := s ++ ", " }
                def a = inner.at(i)
                if ((a != unused) && (a != removed)) then {
                    s := s ++ "{i}→{a.key}::{a.value}"
                } else {
                    s := s ++ "{i}→{a.asDebugString}"
                }
            }
            s ++ "⟭"
        }
        method keys → Enumerable⟦K⟧ {
            def sourceDictionary = self
            object {
                inherit graceObject
                use enumerable⟦K⟧
                class iterator {
                    def sourceIterator = sourceDictionary.bindingsIterator
                    method hasNext { sourceIterator.hasNext }
                    method next { sourceIterator.next.key }
                    method asString {
                        "an iterator over keys of {sourceDictionary}"
                    }
                }
                def size is public = sourceDictionary.size
                method asDebugString {
                    "a lazy sequence over keys of {sourceDictionary}"
                }
            }
        }
        method values → Enumerable⟦T⟧ {
            def sourceDictionary = self
            object {
                inherit graceObject
                use enumerable⟦T⟧
                class iterator {
                    def sourceIterator = sourceDictionary.bindingsIterator
                    // should be request on outer
                    method hasNext { sourceIterator.hasNext }
                    method next { sourceIterator.next.value }
                    method asString {
                        "an iterator over values of {sourceDictionary}"
                    }
                }
                def size is public = sourceDictionary.size
                method asDebugString {
                    "a lazy sequence over values of {sourceDictionary}"
                }
            }
        }
        method bindings → Enumerable⟦T⟧ {
            def sourceDictionary = self
            object {
                inherit graceObject
                use enumerable⟦T⟧
                method iterator { sourceDictionary.bindingsIterator }
                // should be request on outer
                def size is public = sourceDictionary.size
                method asDebugString {
                    "a lazy sequence over bindings of {sourceDictionary}"
                }
            }
        }
        method iterator → Iterator⟦T⟧ { values.iterator }
        class bindingsIterator → Iterator⟦Binding⟦K, T⟧⟧ {
            // this should be confidential, but can't be until `outer` is fixed.
            def imods:Number = mods
            var count := 1
            var idx := 0
            var elt
            method hasNext { size ≥ count }
            method next {
                if (imods != mods) then {
                    ConcurrentModification.raise (outer.asString)
                }
                if (size < count) then { IteratorExhausted.raise "over {outer.asString}" }
                while {
                    elt := inner.at(idx)
                    (elt == unused) || (elt == removed)
                } do {
                    idx := idx + 1
                }
                count := count + 1
                idx := idx + 1
                elt
            }
        }
        method expand is confidential {
            def c = inner.size
            def n = c * 2
            def oldInner = inner
            inner := _prelude.PrimitiveArray.new(n)
            for (0..(n - 1)) do {i→
                inner.at(i)put(unused)
            }
            numBindings := 0
            for (0..(c - 1)) do {i→
                def a = oldInner.at(i)
                if ((a != unused) && {a != removed}) then {
                    self.at(a.key)put(a.value)
                }
            }
        }
        method keysAndValuesDo(block2) {
             for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if ((a != unused) && {a != removed}) then {
                    block2.apply(a.key, a.value)
                }
            }
        }
        method keysDo(block1) {
             for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if ((a != unused) && {a != removed}) then {
                    block1.apply(a.key)
                }
            }
        }
        method valuesDo(block1) {
             for (0..(inner.size-1)) do {i→
                def a = inner.at(i)
                if ((a != unused) && {a != removed}) then {
                    block1.apply(a.value)
                }
            }
        }
        method do(block1) { valuesDo(block1) }

        method ==(other) {
            match (other)
                case {o:Dictionary →
                    if (self.size != o.size) then {return false}
                    self.keysAndValuesDo { k, v →
                        if (o.at(k)ifAbsent{return false} != v) then {
                            return false
                        }
                    }
                    return true
                }
                case {_ →
                    return false
                }
        }

        method copy {
            def newCopy = newDictionary.empty
            self.keysAndValuesDo{ k, v →
                newCopy.at(k)put(v)
            }
            newCopy
        }

        method asDictionary {
            self
        }

        method ++(other) {
            def newDict = self.copy
            other.keysAndValuesDo {k, v →
                newDict.at(k) put(v)
            }
            return newDict
        }

        method --(other) {
            def newDict = newDictionary.empty
            keysAndValuesDo { k, v →
                if (! other.containsKey(k)) then {
                    newDict.at(k) put(v)
                }
            }
            return newDict
        }
    }
}



// start of new code
class twoWayDictionary⟦K,T⟧ {
    use collectionFactory⟦T⟧

    method at(k:K)put(v:T) {
            self.empty.at(k)put(v)
    }

    method asString { "a two-way dictionary factory" }

    class withAll(initialBindings) → Dictionary⟦K,T⟧ {
        inherits newDictionary.withAll 
    }

}




