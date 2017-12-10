function purge_corrupted_data!(cur_package, corrupted_methods)

  Docs.initmeta(cur_package)

  for corrupted_method in corrupted_methods
    delete_method(corrupted_method)
    delete_docstring(cur_package, corrupted_method)
  end

end
