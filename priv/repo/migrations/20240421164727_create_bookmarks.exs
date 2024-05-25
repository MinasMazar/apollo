defmodule Apollo.Repo.Migrations.CreateBookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks) do
      add :url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
