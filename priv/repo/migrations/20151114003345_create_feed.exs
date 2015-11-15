defmodule Exagg.Repo.Migrations.CreateFeed do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :title, :string
      add :url, :string, size: 2000
      add :last_sync, :datetime
      add :unread_count, :integer
      add :sync_status, :string
      add :favicon, :binary
      add :position, :integer
      add :user_id, references(:users)
      add :folder_id, references(:folders)

      timestamps
    end
    create index(:feeds, [:user_id])
    create index(:feeds, [:folder_id])

  end
end
