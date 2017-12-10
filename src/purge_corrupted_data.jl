function purge_corrupted_data!(cur_package, corrupted_methods)
  for corrupted_method in corrupted_methods
    delete_method(corrupted_method)
  end

  Docs.initmeta(cur_package)

  for corrupted_method in corrupted_methods

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
end
