defmodule Exagg.JWT do
  import Joken

  def validate!(token) do
    secret = Application.get_env(:exagg, Exagg.Endpoint)[:secret_key_base]

    token
    |> token()
    |> with_signer(hs256(secret))
    |> with_validation("iat", &(&1 <= current_time))
    |> with_validation("nbf", &(&1 < current_time))
    |> with_validation("exp", &(&1 > current_time))
    |> verify!
  end

  def generate_token(user) do
    secret = Application.get_env(:exagg, Exagg.Endpoint)[:secret_key_base]

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
