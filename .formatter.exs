[
  inputs: [".formatter.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:typed_struct],
  locals_without_parens: [emit: 1, emit: 2],
  plugins: [Styler]
]
