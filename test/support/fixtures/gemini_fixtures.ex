defmodule Apollo.GeminiFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Apollo.Gemini` context.
  """

  @doc """
  Generate a visit.
  """
  def visit_fixture(attrs \\ %{}) do
    {:ok, visit} =
      attrs
      |> Enum.into(%{
        url: "some url"
      })
      |> Apollo.Gemini.create_visit()

    visit
  end
end
