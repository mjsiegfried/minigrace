import "newCollections" as nc

class twoWayDictionary⟦K,T⟧ {
    use nc.collectionFactory⟦T⟧

    method at(k:K)put(v:T) {
        self.empty.at(k)put(v)
    }

    method asString { "a two-way dictionary factory" }

    class withAll(initialBindings)  {
        inherits nc.dictionary.withAll [] 

        var valuesInner := _prelude.PrimitiveArray.new(8)

        method initialize is confidential {
            super.initialize
            for (0..(self.valuesInner.size-1)) do {i→
                self.valuesInner.at(i)put(super.unused)
            } 
            for (initialBindings) do { b → at(b.key)put(b.value) }
        }

        method at(key')put(value') {
            super.at(key')put(value')
            var u := super.findPositionForAdd(value', valuesInner)                            /// refactor findPosition for add
            self.valuesInner.at(u)put(binding.key(value')value(key'))
            self    // for chaining
        }

        method at(k) {
            var pos := super.findPosition(k,inner)
            var b := super.inner.at(pos)
            if (bVal.key == k) then {
                return b.value
            }
            var valPos := super.findPosition(k,valuesInner)
            var bVal := self.valuesInner.at(valPos)
            if (bVal.key == k) then {
                return bVal.value
            }
            NoSuchObject.raise "dictionary does not contain entry with key {k}"
        }

        method at(k) ifAbsent(action) {
            var pos := super.findPosition(k,inner)
            var b := super.inner.at(pos)
            if (b.key == k) then {
                return b.value
            }
            var valPos := super.findPosition(k,valuesInner)
            var bVal := self.valuesInner.at(valPos)
            if (bVal.key == k) then {
                return bVal.value
            }
            action.apply
        }

        method remove(v) {
            self.removeValue(v) ifAbsent { self.removeKey(v) }
        }

        method contains(v) { super.containsValue(v) || super.containsKey(v) }

        method copy {
            def newCopy = twoWayDictionary.empty
            self.super.keysAndValuesDo{ k, v →
                newCopy.at(k)put(v)
            }
            newCopy
        }

        method expand is confidential {
            def c = super.inner.size
            def n = c * 2
            def oldInner = super.inner
            def oldValuesInner = self.valuesInner
            super.inner := _prelude.PrimitiveArray.new(n) 
            self.valuesInner := _prelude.PrimitiveArray.new(n)
            for (0..(n - 1)) do {i→
                super.inner.at(i)put(super.unused)
                self.valuesInner.at(i)put(super.unused)
            }
            super.numBindings := 0
            for (0..(c - 1)) do {i→
                def a = oldInner.at(i)
                if ((a != super.unused) && {a != super.removed}) then {
                    self.at(a.key)put(a.value)
                }
            }
        }

        method --(other) {
            def newDict = twoWayDictionary.empty
            super.keysAndValuesDo { k, v →
                if (! other.containsKey(k)) then {
                    newDict.at(k) put(v)
                }
            }
            return newDict
        }


    }

}




