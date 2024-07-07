# Used by "mix format"
[
  inputs: [".formatter.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:typed_struct],
  plugins: [Styler]
]
