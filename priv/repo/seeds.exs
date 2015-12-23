# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exagg.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Exagg.Repo.insert!(%Exagg.User{username: "admin", hashed_password: Comeonin.Bcrypt.hashpwsalt("admin"), admin: true})
