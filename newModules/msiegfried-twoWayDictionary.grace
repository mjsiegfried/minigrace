import "newCollections" as nc

class twoWayDictionary⟦K,T⟧ {
    use nc.collectionFactory⟦T⟧

    method at(k:K)put(v:T) {
            self.empty.at(k)put(v)
    }

    method asString { "a two-way dictionary factory" }

    class withAll(initialBindings) → Dictionary⟦K,T⟧ {
        inherits nc.dictionary.withAll 
        method at(k) {
            var b := inner.at(findPosition(k))
            if (b.key == k ) then {
                return b.value
            }
            if(b.value == k) then {
                return b.key
            }
            NoSuchObject.raise "dictionary does not contain entry with key {k}"
        }
        method at(k) ifAbsent(action) {
            var b := inner.at(findPosition(k))
            if (b.key == k) then {
                return b.value
            }
            if(b.value == k) then {
                return b.key
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
    }

}




