alias Apollo, as: A
alias A.Gemini, as: G
alias G.Api, as: Api

defmodule Apollo.IEx.Helpers do
  @test_url "gemini://cobradile.cities.yesterweb.org/index.it.gmi"
  def test_url, do: @test_url

  def b(url \\ test_url()), do: G.body(url, :from_api)
  def d(url \\ test_url()), do: G.to_gmi(url)
end

alias A.IEx.Helpers, as: H
