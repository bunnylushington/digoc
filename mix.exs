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

  defp deps do
    [ 
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev},
     {:poison, "~> 1.3.0"},
     {:httpoison, "~> 0.5"}
    ]
  end
end
