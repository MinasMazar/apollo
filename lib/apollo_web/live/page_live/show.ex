defmodule ApolloWeb.PageLive.Show do
  @homepage "gemini://geminiprotocol.net/"
  @initial_navigation %{back_url: nil, current_url: nil, history: []}
  use ApolloWeb, :live_view
  alias Apollo.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, status: "", document: nil, navigation: @initial_navigation)}
  end

  @impl true
  def handle_params(%{"url" => url}, _, socket) do
    gmi = Gemini.to_gmi(url)
    {:noreply,
     socket
     |> assign(:navigate, Map.put(socket.assigns.navigation, :current_url, url))
     |> assign(:document, gmi)}
  end

  def handle_params(params, session, socket) do
    handle_params(Map.merge(params, %{"url" => @homepage}), session, socket)
  end

  @impl true
  def handle_event("navigate", %{"url" => url}, socket) do
    case ApolloWeb.sanitize_target(url, socket.assigns.document) do
      {:ok, uri = %{scheme: "gemini"}} ->
	gmi = Gemini.to_gmi(URI.to_string(uri))

	back_url = URI.to_string(socket.assigns.document.uri)
	current_url = URI.to_string(gmi.uri)
	history = [back_url | socket.assigns.navigation.history]
	navigation = %{socket.assigns.navigation | history: history, current_url: current_url, back_url: back_url}

	{:noreply,
	 socket
	 |> assign(:document, gmi)
	 |> assign(:navigation, navigation)}

      _ -> {:noreply, socket}
    end
  end

  def handle_event("back", _, socket) do
    {:noreply, socket
    |> put_flash(:error, "Back feature not implemented! 😥")}
  end
end
