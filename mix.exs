defmodule Speak.MixProject do
  use Mix.Project

  def project do
    [
      app: :speak,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: [
        {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
        {:ex_doc, "~> 0.18.1", only: [:dev], runtime: false},
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Connor Rigby"],
      links: %{
        "GitHub" => "https://github.com/connorrigby/elixir_speak",
      },
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      source_url: "https://github.com/connorrigby/elixir_speak"
    ]
  end

  defp description do
    """
    Speak all your logs!
    """
  end
end
