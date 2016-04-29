defmodule Release.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:exagg)

    path = Application.app_dir(:exagg, "priv/repo/migrations")

    Ecto.Migrator.run(Exagg.Repo, path, :up, all: true)

    :init.stop()
  end
end

