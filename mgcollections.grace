#pragma DefaultVisibility=public

class list.new(*a) {
    var inner := PrimitiveArray.new(a.size * 2 + 1)
    var size := 0
    for (a) do {x->
        inner.at(size)put(x)
        size := size + 1
    }
    method at(n) {
        inner.at(n-1)
    }
    method [](n) {
        inner.at(n-1)
    }
    method at(n)put(x) {
        inner.at(n-1)put(x)
    }
    method []:=(n,x) {
        inner.at(n-1)put(x)
    }
    method push(x) {
        inner.at(size)put(x)
        size := size + 1
        if (size == inner.size) then {
            expand
        }
    }
    method pop {
        def ret = inner.at(size - 1)
        size := size - 1
        ret
    }
    method asString {
        var s := "list.new("
        for (0..(size-1)) do {i->
            s := s ++ inner.at(i).asString ++ ","
        }
        s ++ ")"
    }
    method extend(l) {
        for (l) do {i->
            push(i)
        }
    }
    method reduce(initial, blk) {
        if (size == 0) then {
            return initial
        }
        var res := initial
        for (self) do {it->
            res := blk.apply(res, it)
        }
        res
    }
    method iter {
        object {
            var idx := 1
            method havemore {
                idx <= size
            }
            method next {
                def ret = at(idx)
                idx := idx + 1
                ret
            }
        }
    }
    method iterator {
        iter
    }
    method expand {
        def c = inner.size
        def n = c * 2
        def newInner = PrimitiveArray.new(n)
        for (0..(size-1)) do {i->
            newInner.at(i)put(inner.at(i))
        }
        inner := newInner
    }
}

class set.new(*a) {
    var inner := PrimitiveArray.new(if (a.size > 1)
        then {a.size * 3 + 1} else {8})
    def unused = object { var unused := true }
    for (0..(inner.size-1)) do {i->
        inner.at(i)put(unused)
    }
    method add(x) {
        def h = x.hashcode
        def s = inner.size
        var t := h % s
        var c := inner.at(t)
        while {c != unused} do {
            if (c == x) then {
                return self
            }
            t := (t * 3 + 1) % s
            c := inner.at(t)
        }
        inner.at(t)put(x)
        size := size + 1
        if (size > (inner.size / 2)) then {
            expand
        }
    }
    method contains(x) {
        def h = x.hashcode
        def s = inner.size
        var t := h % s
        while {inner.at(t) != unused} do {
            if (inner.at(t) == x) then {
                return true
            }
            t := (t * 3 + 1) % s
        }
        return false
    }
    method asString {
        var s := "set.new("
        for (0..(inner.size-1)) do {i->
            if (inner.at(i) != unused) then {
                s := s ++ inner.at(i).asString ++ ","
            }
        }
        s ++ ")"
    }
    method extend(l) {
        for (l) do {i->
            add(i)
        }
    }
    method iter {
        object {
            var count := 1
            var idx := 0
            method havemore {
                count <= size
            }
            method next {
                while {inner.at(idx) == unused} do {
                    idx := idx + 1
                }
                def ret = inner.at(idx)
                count := count + 1
                ret
            }
        }
    }
    method iterator {
        iter
    }
    method expand {
        def c = inner.size
        def n = c * 2
        def oldInner = inner
        inner := PrimitiveArray.new(n)
        for (0..(inner.size-1)) do {i->
            inner.at(i)put(unused)
        }
        for (0..(oldInner.size-1)) do {i->
            if (oldInner.at(i) != unused) then {
                add(oldInner.at(i))
            }
        }
    }
    var size := 0
    for (a) do {x->
        add(x)
        size := size + 1
    }
}