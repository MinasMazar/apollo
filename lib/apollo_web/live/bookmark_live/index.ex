defmodule ApolloWeb.BookmarkLive.Index do
  use ApolloWeb, :live_view

  alias Apollo.Gemini
  alias Apollo.Gemini.Bookmark

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:bookmarks, Gemini.list_bookmarks())
     |> assign(:back, nil)
     |> assign(:current_url, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmark")
    |> assign(:bookmark, Gemini.get_bookmark!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmark")
    |> assign(:bookmark, %Bookmark{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookmarks")
    |> assign(:bookmark, nil)
  end

  @impl true
  def handle_info({ApolloWeb.BookmarkLive.FormComponent, {:saved, bookmark}}, socket) do
    {:noreply, stream_insert(socket, :bookmarks, bookmark)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Gemini.get_bookmark!(id)
    {:ok, _} = Gemini.delete_bookmark(bookmark)

    {:noreply, stream_delete(socket, :bookmarks, bookmark)}
  end
end
