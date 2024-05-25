defmodule ApolloWeb.PageLive.Show do
  use ApolloWeb, :live_view

  alias Apollo.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, gmi: nil, url: nil, back: nil)}
  end

  @impl true
  def handle_params(%{"url" => url}, _, socket) do
    visit = %Gemini.Visit{url: url}
    gmi = Gemini.to_gmi(visit)

    {:noreply,
     socket
     |> assign(:page_title, "SHOW")
     |> assign(:url, url)
     |> assign(:back, socket.assigns.back || url)
     |> assign(:gmi, gmi)}
  end

  @homepage "gemini://geminiprotocol.net/"
  def handle_params(params, session, socket) do
    handle_params(Map.merge(params, %{"url" => @homepage}), session, socket)
  end
end
