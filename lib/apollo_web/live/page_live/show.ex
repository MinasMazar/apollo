defmodule ApolloWeb.PageLive.Show do
  use ApolloWeb, :live_view

  alias Apollo.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, status: "", document: nil, back: nil, current_url: nil, history: [])}
  end

  @impl true
  def handle_params(%{"url" => url}, _, socket) do
    gmi = Gemini.to_gmi(url)
    {:noreply,
     socket
     |> assign(:current_url, url)
     |> assign(:document, gmi)}
  end

  @homepage "gemini://geminiprotocol.net/"
  def handle_params(params, session, socket) do
    handle_params(Map.merge(params, %{"url" => @homepage}), session, socket)
  end

  @impl true
  def handle_event("navigate", %{"url" => url}, socket) do
    history = [socket.assigns.document.uri | socket.assigns.history]
    case ApolloWeb.sanitize_target(url, socket.assigns.document) do
      {:ok, uri = %{scheme: "gemini"}} ->
	gmi = Gemini.to_gmi(URI.to_string(uri))
	{:noreply,
	 socket
	 |> assign(:current_url, URI.to_string(gmi.document.uri))
	 |> assign(:history, history)
	 |> assign(:document, gmi)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("back", _, socket) do
    [new_url | new_history] = socket.assigns.history
    handle_event("navigate", %{"url" => new_url}, assign(socket, :history, new_history))
  end
end
