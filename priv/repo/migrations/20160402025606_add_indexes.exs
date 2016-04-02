defmodule Exagg.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create index(:folders, [:position])
    create index(:feeds, [:position])
    create index(:items, [:date])
  end
end
