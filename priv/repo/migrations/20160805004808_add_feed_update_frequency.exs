defmodule Exagg.Repo.Migrations.AddFeedUpdateFrequency do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      add :update_frequency, :integer, default: 0
      add :auto_frequency, :boolean, default: true
      modify :last_sync, :datetime, default: fragment("now()")
    end
  end
end
