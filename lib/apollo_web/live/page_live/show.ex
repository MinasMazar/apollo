defmodule ApolloWeb.PageLive.Show do
  use ApolloWeb, :live_view

  alias Apollo.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, document: nil, back: nil)}
  end

  @impl true
  def handle_params(%{"url" => url}, _, socket) do
    gmi = Gemini.to_gmi(url)

    {:noreply,
     socket
     |> assign(:page_title, "SHOW")
     |> assign(:document, gmi)}
  end

  @homepage "gemini://geminiprotocol.net/"
  def handle_params(params, session, socket) do
    handle_params(Map.merge(params, %{"url" => @homepage}), session, socket)
  end
end
