defmodule Apollo.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
