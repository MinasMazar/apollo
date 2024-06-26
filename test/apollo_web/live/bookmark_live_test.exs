defmodule ApolloWeb.BookmarkLiveTest do
  use ApolloWeb.ConnCase

  import Phoenix.LiveViewTest
  import Apollo.GeminiFixtures

  @create_attrs %{url: "some url"}
  @update_attrs %{url: "some updated url"}
  @invalid_attrs %{url: nil}

  defp create_bookmark(_) do
    bookmark = bookmark_fixture()
    %{bookmark: bookmark}
  end

  describe "Index" do
    setup [:create_bookmark]

    test "lists all bookmarks", %{conn: conn, bookmark: bookmark} do
      {:ok, _index_live, html} = live(conn, ~p"/bookmarks")

      assert html =~ "Listing Bookmarks"
      assert html =~ bookmark.url
    end

    test "saves new bookmark", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bookmarks")

      assert index_live |> element("a", "New Bookmark") |> render_click() =~
               "New Bookmark"

      assert_patch(index_live, ~p"/bookmarks/new")

      assert index_live
             |> form("#bookmark-form", bookmark: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bookmark-form", bookmark: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bookmarks")

      html = render(index_live)
      assert html =~ "Bookmark created successfully"
      assert html =~ "some url"
    end

    test "updates bookmark in listing", %{conn: conn, bookmark: bookmark} do
      {:ok, index_live, _html} = live(conn, ~p"/bookmarks")

      assert index_live |> element("#bookmarks-#{bookmark.id} a", "Edit") |> render_click() =~
               "Edit Bookmark"

      assert_patch(index_live, ~p"/bookmarks/#{bookmark}/edit")

      assert index_live
             |> form("#bookmark-form", bookmark: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bookmark-form", bookmark: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bookmarks")

      html = render(index_live)
      assert html =~ "Bookmark updated successfully"
      assert html =~ "some updated url"
    end

    test "deletes bookmark in listing", %{conn: conn, bookmark: bookmark} do
      {:ok, index_live, _html} = live(conn, ~p"/bookmarks")

      assert index_live |> element("#bookmarks-#{bookmark.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bookmarks-#{bookmark.id}")
    end
  end

  describe "Show" do
    setup [:create_bookmark]

    test "displays bookmark", %{conn: conn, bookmark: bookmark} do
      {:ok, _show_live, html} = live(conn, ~p"/bookmarks/#{bookmark}")

      assert html =~ "Show Bookmark"
      assert html =~ bookmark.url
    end

    test "updates bookmark within modal", %{conn: conn, bookmark: bookmark} do
      {:ok, show_live, _html} = live(conn, ~p"/bookmarks/#{bookmark}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Bookmark"

      assert_patch(show_live, ~p"/bookmarks/#{bookmark}/show/edit")

      assert show_live
             |> form("#bookmark-form", bookmark: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#bookmark-form", bookmark: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bookmarks/#{bookmark}")

      html = render(show_live)
      assert html =~ "Bookmark updated successfully"
      assert html =~ "some updated url"
    end
  end
end
