defmodule Apollo.Gemini.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :url, :string
    field :body, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:url, :body])
    |> validate_required([:url])
  end

  def uri(visit) do
    with {:ok, uri} <- URI.new(visit.url), do: uri, else: (_ -> raise ArgumentError)
  end
end
