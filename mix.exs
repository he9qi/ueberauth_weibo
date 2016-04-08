defmodule UeberauthWeibo.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :ueberauth_weibo,
     version: @version,
     package: package,
     name: "Ueberauth Weibo",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/he9qi/ueberauth_weibo",
     homepage_url: "https://github.com/he9qi/ueberauth_weibo",
     description: description,
     deps: deps,
     docs: docs]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :ueberauth, :oauth2]]
  end

  # Dependencies can be Hex packages:
  defp deps do
    [{:ueberauth, "~> 0.2"},
     {:oauth2, "~> 0.5"},

     # docs dependencies
     {:earmark, "~>0.1", only: :dev},
     {:ex_doc, "~>0.1", only: :dev}]
  end

  defp docs do
    [extras: ["README.md"], main: "readme"]
  end

  defp description do
    "An Ueberauth strategy for using Weibo to authenticate your users."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Qi He"],
      licenses: ["MIT"],
      links: %{"Github": "https://github.com/he9qi/ueberauth_weibo"}]
  end
end
