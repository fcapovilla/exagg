defmodule Exagg.UserView do
  use Exagg.Web, :view

  def render("user.json", %{token: token, user: _}) do
    %{token: token}
  end
end
