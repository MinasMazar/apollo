defmodule ApolloWeb.CacheLive.Index do
  use ApolloWeb, :live_view

  alias Apollo.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookmarks")
    |> stream(:cache, [])
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Gemini.get_bookmark!(id)
    {:ok, _} = Gemini.delete_bookmark(bookmark)

    {:noreply, stream_delete(socket, :bookmarks, bookmark)}
  end
end
