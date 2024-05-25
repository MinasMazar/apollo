defmodule Apollo.GeminiTest do
  use Apollo.DataCase

  alias Apollo.Gemini

  describe "bookmarks" do
    alias Apollo.Gemini.Bookmark

    import Apollo.GeminiFixtures

    @invalid_attrs %{url: nil}

    test "list_bookmarks/0 returns all bookmarks" do
      bookmark = bookmark_fixture()
      assert Gemini.list_bookmarks() == [bookmark]
    end

    test "get_bookmark!/1 returns the bookmark with given id" do
      bookmark = bookmark_fixture()
      assert Gemini.get_bookmark!(bookmark.id) == bookmark
    end

    test "create_bookmark/1 with valid data creates a bookmark" do
      valid_attrs = %{url: "some url"}

      assert {:ok, %Bookmark{} = bookmark} = Gemini.create_bookmark(valid_attrs)
      assert bookmark.url == "some url"
    end

    test "create_bookmark/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gemini.create_bookmark(@invalid_attrs)
    end

    test "update_bookmark/2 with valid data updates the bookmark" do
      bookmark = bookmark_fixture()
      update_attrs = %{url: "some updated url"}

      assert {:ok, %Bookmark{} = bookmark} = Gemini.update_bookmark(bookmark, update_attrs)
      assert bookmark.url == "some updated url"
    end

    test "update_bookmark/2 with invalid data returns error changeset" do
      bookmark = bookmark_fixture()
      assert {:error, %Ecto.Changeset{}} = Gemini.update_bookmark(bookmark, @invalid_attrs)
      assert bookmark == Gemini.get_bookmark!(bookmark.id)
    end

    test "delete_bookmark/1 deletes the bookmark" do
      bookmark = bookmark_fixture()
      assert {:ok, %Bookmark{}} = Gemini.delete_bookmark(bookmark)
      assert_raise Ecto.NoResultsError, fn -> Gemini.get_bookmark!(bookmark.id) end
    end

    test "change_bookmark/1 returns a bookmark changeset" do
      bookmark = bookmark_fixture()
      assert %Ecto.Changeset{} = Gemini.change_bookmark(bookmark)
    end
  end
end
