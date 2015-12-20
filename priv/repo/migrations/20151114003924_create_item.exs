defmodule Exagg.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :title, :text
      add :url, :string, size: 2000
      add :guid, :string
      add :content, :text
      add :read, :boolean, default: false
      add :favorite, :boolean, default: false
      add :date, :datetime
      add :orig_feed_title, :text
      add :user_id, references(:users, on_delete: :delete_all)
      add :feed_id, references(:feeds, on_delete: :delete_all)

      timestamps
    end
    create index(:items, [:user_id])
    create index(:items, [:feed_id])
    create unique_index(:items, [:guid])

  end
end
