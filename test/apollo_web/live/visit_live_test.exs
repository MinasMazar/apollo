defmodule ApolloWeb.VisitLiveTest do
  use ApolloWeb.ConnCase

  import Phoenix.LiveViewTest
  import Apollo.GeminiFixtures

  @create_attrs %{url: "some url"}
  @update_attrs %{url: "some updated url"}
  @invalid_attrs %{url: nil}

  defp create_visit(_) do
    visit = visit_fixture()
    %{visit: visit}
  end

  describe "Index" do
    setup [:create_visit]

    test "lists all visits", %{conn: conn, visit: visit} do
      {:ok, _index_live, html} = live(conn, ~p"/visits")

      assert html =~ "Listing Visits"
      assert html =~ visit.url
    end

    test "saves new visit", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/visits")

      assert index_live |> element("a", "New Visit") |> render_click() =~
               "New Visit"

      assert_patch(index_live, ~p"/visits/new")

      assert index_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#visit-form", visit: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/visits")

      html = render(index_live)
      assert html =~ "Visit created successfully"
      assert html =~ "some url"
    end

    test "updates visit in listing", %{conn: conn, visit: visit} do
      {:ok, index_live, _html} = live(conn, ~p"/visits")

      assert index_live |> element("#visits-#{visit.id} a", "Edit") |> render_click() =~
               "Edit Visit"

      assert_patch(index_live, ~p"/visits/#{visit}/edit")

      assert index_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#visit-form", visit: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/visits")

      html = render(index_live)
      assert html =~ "Visit updated successfully"
      assert html =~ "some updated url"
    end

    test "deletes visit in listing", %{conn: conn, visit: visit} do
      {:ok, index_live, _html} = live(conn, ~p"/visits")

      assert index_live |> element("#visits-#{visit.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#visits-#{visit.id}")
    end
  end

  describe "Show" do
    setup [:create_visit]

    test "displays visit", %{conn: conn, visit: visit} do
      {:ok, _show_live, html} = live(conn, ~p"/visits/#{visit}")

      assert html =~ "Show Visit"
      assert html =~ visit.url
    end

    test "updates visit within modal", %{conn: conn, visit: visit} do
      {:ok, show_live, _html} = live(conn, ~p"/visits/#{visit}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Visit"

      assert_patch(show_live, ~p"/visits/#{visit}/show/edit")

      assert show_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#visit-form", visit: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/visits/#{visit}")

      html = render(show_live)
      assert html =~ "Visit updated successfully"
      assert html =~ "some updated url"
    end
  end
end