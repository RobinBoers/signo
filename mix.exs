defmodule Signo.MixProject do
  use Mix.Project

  def project, do: [
    name: "Signo",
    app: :signo,
    version: "0.1.0",
    elixir: "~> 1.16",
    start_permanent: Mix.env() == :prod,
    dialyzer: [plt_add_apps: [:mix]],
    deps: deps(),

    # Docs
    source_url: "https://git.dupunkto.org/axcelott/signo",
    homepage_url: "https://ftp.dupunkto.org/~axcelott/signo",
    docs: docs()
  ]

  def application, do: [
    extra_applications: [:logger]
  ]

  defp deps, do: [
    {:typed_struct, "~> 0.3.0"},
    {:ex_doc, "~> 0.31", only: :dev, runtime: false},
    {:credo, ">= 0.0.0", only: :dev, runtime: false},
    {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
    {:ex_check, "~> 0.14.0", only: :dev, runtime: false},
    {:styler, "~> 0.11", only: :dev, runtime: false}
  ]

  defp docs, do: [
    main: "Signo",
    api_reference: false,
    authors: ["Robijntje"],
    formatters: ["html"],
    extras: [
      "docs/introduction.md",
      "docs/basic-types.md",
      "docs/language-features.md",
      "docs/procedures.md",
      "docs/immutability.md",
      "docs/example.md"
    ],
    groups_for_modules: [
      "Standard Library": [Signo.StdLib, Signo.SpecialForms],
      "AST": [~r/Signo.AST/]
    ],
    groups_for_docs: [
      General: & &1[:section] == :general,
      Operators: & &1[:section] == :operators,
      Numbers: & &1[:section] == :numbers,
      Math: & &1[:section] == :math,
      Strings: & &1[:section] == :strings,
      Lists: & &1[:section] == :lists,
      REPL: & &1[:section] == :repl
    ]
  ]
end
