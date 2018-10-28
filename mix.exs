defmodule Pbuf.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :pbuf,
      deps: deps(),
      elixir: "~> 1.6",
      version: @version,
      escript: escript(),
      elixirc_paths: paths(Mix.env),
      description: "A fast protocol buffer library",
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/karlseguin/pbuf"
        },
        maintainers: ["Karl Seguin"],
      ],
    ]
  end

  defp paths(:test), do: paths(:prod) ++ ["test/support", "test/schemas/generated"]
  defp paths(_), do: ["lib", "web"]

  defp escript do
    [main_module: Pbuf.Protoc, name: "protoc-gen-fast-elixir", app: nil]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:protobuf, "~> 0.5.4"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
