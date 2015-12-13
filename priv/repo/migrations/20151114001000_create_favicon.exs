defmodule Exagg.Repo.Migrations.CreateFavicon do
  use Ecto.Migration

  def change do
    create table(:favicons) do
      add :host, :string
      add :data, :text

      timestamps
    end

  end
end
