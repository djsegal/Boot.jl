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
