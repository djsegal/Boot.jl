function purge_corrupted_methods!(cur_package, corrupted_methods)

  Docs.initmeta(cur_package)

  for cur_method in corrupted_methods
    delete_method(cur_method)
    delete_docstring(cur_package, cur_method)
  end

end

function delete_docstring(cur_package, corrupted_method)

  corrupted_method_name = corrupted_method.name

  b = Docs.Binding(cur_package, corrupted_method_name)
  m = get!(Docs.meta(cur_package), b, Docs.MultiDoc())

  cur_sig_string = string(corrupted_method.sig)

  cur_sig_string = replace(cur_sig_string, "$(cur_package).#$(corrupted_method_name)", "")

  cur_sig_string = replace(cur_sig_string, "{,", "{")

  cur_sig = cur_package.eval(parse(string(cur_sig_string)))

  cur_keys = collect(keys(m.docs))

  for cur_key in cur_keys
    ( cur_sig <: cur_key ) || continue

    delete!(m.docs, cur_key)
  end

end

if !isdefined(Boot, :themethod)
  const themethod = Ref{Any}(nothing)
end

function delete_method(m::Method)
    # While methods(getfield(m.module, m.name)) works in many cases, it fails when
    # a nonex-ported function is extended by a different module.
    # Invalidate the cache of the callers
    try
    invalidate_callers(m.specializations)
    # Remove from method list
    mt = get_methodtable(m.sig)
    ml = Base.MethodList(mt)
    drop_from_tme!(mt, :defs, m)
    # Delete compiled instances of this method from the cache
    drop_from_tme!(mt, :cache, m)
    # Delete this signature
    deleteat!(ml.ms, findfirst(x->x==m, ml.ms))
    catch err
        themethod[] = m
        showerror(STDERR, err)
        rethrow(err)
    end
nothing
end

delete_method(::Void) = nothing

get_methodtable(u::UnionAll) = get_methodtable(u.body)
get_methodtable(sig) = _get_methodtable(sig.parameters[1])
_get_methodtable(u::UnionAll) = (@show u; _get_methodtable(u.body))
_get_methodtable(f) = f.name.mt

invalidate_callers(::Void) = nothing

function invalidate_callers(tml::TypeMapLevel)
    global themethod
    println("here")
    themethod[] = tml
    nothing
end

function invalidate_callers(tme::TypeMapEntry)
    while isa(tme, TypeMapEntry)
        invalidate_callers(tme.func)
        tme = tme.next
    end
    nothing
end

function invalidate_callers(mi::Core.MethodInstance, iddict=ObjectIdDict())
    iddict[mi] = true
    if isdefined(mi, :backedges)
        for c in mi.backedges
            haskey(iddict, c) && continue
            invalidate_callers(c, iddict)
        end
    end
    mtc = get_methodtable(mi.def.sig)
    drop_from_tme!(mtc, :cache, mi)
    drop_from_tme!(mi.def, :specializations, mi)
end

function drop_from_tme!(mt::Union{MethodTable,Method}, fn::Symbol, m::Union{Method,Core.MethodInstance})
    nodeprev, node = nothing, getfield(mt, fn)
    while isa(node, TypeMapEntry)
        if node.func === m
            if nodeprev == nothing
                setfield!(mt, fn, node.next)
            else
                nodeprev.next = node.next
            end
        end
        nodeprev, node = node, node.next
    end
    mt
end
