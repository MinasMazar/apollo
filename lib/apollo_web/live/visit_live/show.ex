defmodule ApolloWeb.VisitLive.Show do
  use ApolloWeb, :live_view

  alias Apollo.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"url" => url}, _, socket) do
    visit = %Gemini.Visit{url: url}
    gmi = Gemini.to_gmi(visit)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:visit, Map.put(visit, :gmi, gmi))}
  end

  def handle_params(%{"id" => id}, _, socket) do
    visit = Gemini.get_visit!(id)
    {:noreply,
     socket
     |> assign(:visit, visit)}
  end

  defp page_title(:show), do: "Show Visit"
  defp page_title(:edit), do: "Edit Visit"
end
