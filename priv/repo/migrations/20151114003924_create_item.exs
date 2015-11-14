defmodule Exagg.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :title, :string
      add :url, :string
      add :guid, :string
      add :content, :string
      add :medias, {:array, :map}, default: []
      add :read, :boolean, default: false
      add :favorite, :boolean, default: false
      add :date, :datetime
      add :orig_feed_title, :string
      add :user_id, references(:users)
      add :feed_id, references(:feeds)

      timestamps
    end
    create index(:items, [:user_id])
    create index(:items, [:feed_id])
    create unique_index(:items, [:guid])

  end
end
