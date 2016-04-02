defmodule Exagg.UserView do
  use Exagg.Web, :view
  use JaSerializer.PhoenixView

  location "/users/:id"
  attributes [:username, :admin, :password]

  def password(_struct, _conn) do
    "********"
  end

  def render("user.json", %{token: token, user: _user}) do
    %{token: token}
  end
end
