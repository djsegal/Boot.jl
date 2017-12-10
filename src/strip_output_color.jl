function strip_output_color(cur_string::AbstractString)
  replace(cur_string, r"\e[^m]*m", "")
end
