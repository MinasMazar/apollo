defmodule Apollo.Gemini.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :url, :string
    field :back, :string, virtual: true
    field :body, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:url, :body, :back])
    |> validate_required([:url])
  end
end
