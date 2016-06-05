import "newCollections" as nc

class twoWayDictionary⟦K,T⟧ {
    use nc.collectionFactory⟦T⟧

    method at(k:K)put(v:T) {
            self.empty.at(k)put(v)
    }

    method asString { "a two-way dictionary factory" }

    class withAll(initialBindings) → Dictionary⟦K,T⟧ {
        inherits nc.dictionary.withAll 
    }

}




