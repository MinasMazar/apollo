defmodule Apollo.Gemini.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
