defmodule Exagg.UserView do
  use Exagg.Web, :view

  def render("user.json", %{token: token, user: user}) do
    %{token: token}
  end
end
