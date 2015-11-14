defmodule Exagg.Repo.Migrations.CreateFolder do
  use Ecto.Migration

  def change do
    create table(:folders) do
      add :title, :string
      add :open, :boolean, default: false
      add :position, :integer
      add :user_id, references(:users)

      timestamps
    end
    create index(:folders, [:user_id])

  end
end
