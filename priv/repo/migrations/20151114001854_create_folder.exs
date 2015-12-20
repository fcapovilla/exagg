defmodule Exagg.Repo.Migrations.CreateFolder do
  use Ecto.Migration

  def change do
    create table(:folders) do
      add :title, :text
      add :open, :boolean, default: false
      add :position, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps
    end
    create index(:folders, [:user_id])
    create unique_index(:folders, [:title])

  end
end
