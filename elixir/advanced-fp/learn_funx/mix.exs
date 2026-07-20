defmodule LearnFunx.MixProject do
  use Mix.Project

  def project do
    [
      app: :learn_funx,
      version: "0.1.0",
      elixir: "~> 1.16 or ~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Learn Funx",
      description:
        "Practice environment for functional programming in Elixir using the Funx library.",
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/JKWA/learn_funx",
          "Funx Library" => "https://hex.pm/packages/funx",
          "Book" =>
            "https://pragprog.com/titles/jkelixir/advanced-functional-programming-with-elixir"
        }
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:funx, git: "https://github.com/JKWA/funx.git", branch: "main"}
    ]
  end
end
