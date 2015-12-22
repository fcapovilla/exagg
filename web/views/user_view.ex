defmodule Exagg.UserView do
  use Exagg.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Exagg.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Exagg.UserView, "user.json")}
  end

  def render("user.json", %{token: token, user: _user}) do
    %{token: token}
  end
  def render("user.json", %{user: user}) do
    %{type: "users",
      id: user.id,
      attributes: %{
        username: user.username,
        password: "********",
        admin: user.admin
      }
    }
  end
end
