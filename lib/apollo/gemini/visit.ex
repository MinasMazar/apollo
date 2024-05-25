defmodule Apollo.Gemini.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :url, :string
    field :back, :string, virtual: true
    field :body, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:url, :body, :back])
    |> validate_required([:url])
  end
end
