defmodule ApolloWeb.Helpers do
  require Logger
  def back_location(url) do
    url || ""
  end

  def current_url(document) do
    Map.get(document, :uri, "unmatch")
  end
end
