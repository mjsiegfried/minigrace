import "newCollections" as nc

class twoWayDictionary⟦K,T⟧ {
    use nc.collectionFactory⟦T⟧

    method at(k:K)put(v:T) {
            self.empty.at(k)put(v)
    }

    method asString { "a two-way dictionary factory" }

    class withAll(initialBindings) → Dictionary⟦K,T⟧ {
        inherits nc.dictionary.withAll(initialBindings) 
        var valuesInner := _prelude.PrimitiveArray.new(8)

        for (0..(valuesInner.size-1)) do {i→
            valuesInner.at(i)put(unused)
        }

        method at(key')put(value') {
            super.at(key')put(value')
            var u := findPositionForAdd(value')
            valuesInner.at(u)put(binding.key(value')value(key'))
            self    // for chaining
        }

        method at(k) {
            var pos := findPosition(k)
            var b := inner.at(pos)
            if (bVal.key == k) then {
                return b.value
            }
            var bVal := valuesInner.at(pos)
            if (bVal.key == k) then {
                return bVal.value
            }
            NoSuchObject.raise "dictionary does not contain entry with key {k}"
        }

        method at(k) ifAbsent(action) {
            var pos := findPosition(k)
            var b := inner.at(pos)
            if (b.key == k) then {
                return b.value
            }
            var bVal := valuesInner.at(pos)
            if (bVal.key == k) then {
                return bVal.value
            }
            action.apply
        }

        method remove(v) {
            self.removeValue(v) ifAbsent { self.removeKey(v) }
        }

        method contains(v) { containsValue(v) || containsKey(v) }

        method copy {
            def newCopy = twoWayDictionary.empty
            self.keysAndValuesDo{ k, v →
                newCopy.at(k)put(v)
            }
            newCopy
        }

        method expand is confidential {
            def c = inner.size
            def n = c * 2
            def oldInner = inner
            def oldValuesInner = valuesInner
            inner := _prelude.PrimitiveArray.new(n) 
            valuesInner := _prelude.PrimitiveArray.new(n)
            for (0..(n - 1)) do {i→
                inner.at(i)put(unused)
                valuesInner.at(i)put(unused)
            }
            numBindings := 0
            for (0..(c - 1)) do {i→
                def a = oldInner.at(i)
                if ((a != unused) && {a != removed}) then {
                    self.at(a.key)put(a.value)
                }
            }
        }

        method --(other) {
            def newDict = twoWayDictionary.empty
            keysAndValuesDo { k, v →
                if (! other.containsKey(k)) then {
                    newDict.at(k) put(v)
                }
            }
            return newDict
        }


    }

}




