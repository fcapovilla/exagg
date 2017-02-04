defmodule Exagg.Repo.Migrations.AddCoherenceToUser do
  use Ecto.Migration

  def change do
    rename table(:users), :hashed_password, to: :password_hash
  end
end
