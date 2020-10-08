defmodule Pbuf.MixProject do
  use Mix.Project

  @version "0.1.13"

  def project do
    [
      app: :pbuf,
      deps: deps(),
      elixir: "~> 1.8",
      version: @version,
      escript: escript(),
      elixirc_paths: paths(Mix.env),
      description: "A fast protocol buffer library",
      package: [
        licenses: ["MIT"],
        links: %{
          "git" => "https://github.com/karlseguin/pbuf"
        },
        maintainers: ["Karl Seguin"],
      ],
    ]
  end

  defp paths(:test), do: paths(:prod) ++ ["test/support", "test/schemas/generated"]
  defp paths(_), do: ["lib"]

  defp escript do
    [main_module: Pbuf.Protoc, name: "protoc-gen-fast-elixir", app: nil]
  end

  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:jason, ">= 1.2.2"},
      {:benchee, "~> 1.0.1", only: :test},
      {:protobuf, "~> 0.7.1", only: [:test]},
      {:ex_doc, "~> 0.22.6", only: :dev, runtime: false}
    ]
  end
end
