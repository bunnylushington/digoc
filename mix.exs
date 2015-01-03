defmodule DigOc.Mixfile do
  use Mix.Project

  def project do
    [app: :digoc,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: { DigOc.Supervisor, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [ 
     {:poison, "~> 1.3.0"},
     {:httpoison, "~> 0.5"}
    ]
  end
end
