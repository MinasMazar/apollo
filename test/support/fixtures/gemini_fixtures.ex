defmodule Apollo.GeminiFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Apollo.Gemini` context.
  """

  @doc """
  Generate a bookmark.
  """
  def bookmark_fixture(attrs \\ %{}) do
    {:ok, bookmark} =
      attrs
      |> Enum.into(%{
        url: "some url"
      })
      |> Apollo.Gemini.create_bookmark()

    bookmark
  end
end
