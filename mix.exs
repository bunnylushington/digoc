defmodule DigOc.Mixfile do
  use Mix.Project

  def project do
    [app: :digoc,
     version: "0.3.0",
     elixir: "~> 1.0",
     description: "An Elixir client for the Digital Ocean API v2.",
     package: package,
     docs: [
            source_url: "https://github.com/kevinmontuori/digoc",
            homepage_url: "https://kevinmontuori.github.io/digoc/doc",
            main: "DigOc"
       ],
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: { DigOc.Supervisor, []}]
  end

  def package do
    [
     files: ["lib", "mix.exs", "README*", "LICENSE*", "test"],
     contributors: ["Kevin Montuori"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/kevinmontuori/digoc",
              "Documentation" => "https://kevinmontuori.github.io/digoc"}
    ]
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
