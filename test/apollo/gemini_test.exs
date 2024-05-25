defmodule Apollo.GeminiTest do
  use Apollo.DataCase

  alias Apollo.Gemini

  describe "visits" do
    alias Apollo.Gemini.Visit

    import Apollo.GeminiFixtures

    @invalid_attrs %{url: nil}

    test "list_visits/0 returns all visits" do
      visit = visit_fixture()
      assert Gemini.list_visits() == [visit]
    end

    test "get_visit!/1 returns the visit with given id" do
      visit = visit_fixture()
      assert Gemini.get_visit!(visit.id) == visit
    end

    test "create_visit/1 with valid data creates a visit" do
      valid_attrs = %{url: "some url"}

      assert {:ok, %Visit{} = visit} = Gemini.create_visit(valid_attrs)
      assert visit.url == "some url"
    end

    test "create_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gemini.create_visit(@invalid_attrs)
    end

    test "update_visit/2 with valid data updates the visit" do
      visit = visit_fixture()
      update_attrs = %{url: "some updated url"}

      assert {:ok, %Visit{} = visit} = Gemini.update_visit(visit, update_attrs)
      assert visit.url == "some updated url"
    end

    test "update_visit/2 with invalid data returns error changeset" do
      visit = visit_fixture()
      assert {:error, %Ecto.Changeset{}} = Gemini.update_visit(visit, @invalid_attrs)
      assert visit == Gemini.get_visit!(visit.id)
    end

    test "delete_visit/1 deletes the visit" do
      visit = visit_fixture()
      assert {:ok, %Visit{}} = Gemini.delete_visit(visit)
      assert_raise Ecto.NoResultsError, fn -> Gemini.get_visit!(visit.id) end
    end

    test "change_visit/1 returns a visit changeset" do
      visit = visit_fixture()
      assert %Ecto.Changeset{} = Gemini.change_visit(visit)
    end
  end
end
