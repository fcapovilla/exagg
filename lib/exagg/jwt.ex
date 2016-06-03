defmodule Exagg.JWT do
  import Joken

  def validate!(token, conn = %Plug.Conn{}) do
    validate!(token, conn.secret_key_base)
  end
  def validate!(token, secret) do
    token
    |> token()
    |> with_signer(hs256(secret))
    |> with_validation("iat", &(&1 <= current_time))
    |> with_validation("nbf", &(&1 < current_time))
    |> with_validation("exp", &(&1 > current_time))
    |> verify!
  end

  def generate_token(user, conn = %Plug.Conn{}) do
    generate_token(user, conn.secret_key_base)
  end
  def generate_token(user, secret) do
    %{user: %{id: user.id, username: user.username, admin: user.admin}}
    |> token()
    |> with_signer(hs256(secret))
    |> with_exp
    |> with_iat
    |> with_nbf
    |> sign
    |> get_compact
  end
end
