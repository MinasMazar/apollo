defmodule ApolloWeb.PageLive.Show do
  use ApolloWeb, :live_view

  alias Apollo.Gemini

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, status: "", document: nil, back: nil)}
  end

  @impl true
  def handle_params(%{"url" => url}, _, socket) do
    gmi = Gemini.to_gmi(url)
    {:noreply,
     socket
     |> assign(:document, gmi)}
  end

  @homepage "gemini://geminiprotocol.net/"
  def handle_params(params, session, socket) do
    handle_params(Map.merge(params, %{"url" => @homepage}), session, socket)
  end

  def handle_event("navigate", %{"url" => url}, socket) do
    back = socket.assigns.document.uri
    case ApolloWeb.sanitize_target(url, socket.assigns.document) do
      {:ok, uri = %{scheme: "gemini"}} ->
	gmi = Gemini.to_gmi(URI.to_string(uri))
	{:noreply,
	 socket
	 |> assign(:back, back)
	 |> assign(:document, gmi)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("back", _, socket) do
    handle_event("navigate", %{"url" => socket.assigns.back}, socket)
  end
end
