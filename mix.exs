defmodule Signo.MixProject do
  use Mix.Project

  def project, do: [
    name: "Signo",
    app: :signo,
    version: "0.1.0",
    elixir: "~> 1.16",
    start_permanent: Mix.env() == :prod,
    deps: deps(),

    # Docs
    source_url: "https://git.dupunkto.org/axcelott/signo",
    homepage_url: "https://roblog.nl/projects",
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
    {:ex_check, "~> 0.14.0", only: :dev, runtime: false}
  ]

  defp docs, do: [
    main: "Signo",
    api_reference: false,
    authors: ["Robijntje"],
    formatters: ["html"],
    groups_for_modules: [
      "Standard Library": [Signo.StdLib],
      "AST": [~r/Signo.AST/]
    ]
  ]
end
