# Boot.jl

[![Build Status](https://travis-ci.org/djsegal/Boot.jl.svg?branch=master)](https://travis-ci.org/djsegal/Boot.jl) [![codecov.io](http://codecov.io/github/djsegal/Boot.jl/coverage.svg?branch=master)](http://codecov.io/github/djsegal/Boot.jl?branch=master)

Tool for bootloading Julia packages.

## Usage

Boot.jl is for loading subdirectories in packages.

It can be used to simplify the following code:

```julia
module Foo

  include("math/int.jl")
  include("math/float.jl")

  include("math/ops/plus.jl")
  include("math/ops/minus.jl")
  include("math/ops/times.jl")
  include("math/ops/divide.jl")

  include("math/calc/int.jl")
  include("math/calc/diff.jl")

end
```

to the easier to maintain:

```julia
module Foo

  using Boot

  include_folder(Boot, @__FILE__)

end
```

// note that this is robust against file interdependencies (i.e. if `a.jl` depends on `c.jl` and `c.jl` depends on `b.jl`)

## Tips

To avoid passing your package to Boot every time, you can modify this code:

```julia
module Foo

  using Boot

  include_folder(Boot, @__FILE__)

end
```

to (the seemingly more obfuscated [but much more useful])

```julia
module Foo

  using Boot

  include_folder(varargs...; kwargs...) =
    Boot.include_folder(Foo, varargs...; kwargs...)

  include_folder(@__FILE__)

end
```
