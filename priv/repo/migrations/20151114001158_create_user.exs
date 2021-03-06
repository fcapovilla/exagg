defmodule Exagg.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :hashed_password, :string
      add :admin, :boolean, default: false

      timestamps
    end
    create unique_index(:users, [:username])

  end
end
