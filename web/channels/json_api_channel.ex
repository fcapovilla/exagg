defmodule Exagg.JsonApiChannel do
  use Exagg.Web, :channel

  def join("jsonapi:stream:" <> user_id, payload, socket) do
    if authorized?(String.to_integer(user_id), payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  defp authorized?(user_id, payload) do
    import Joken

    secret = Application.get_env(:exagg, Exagg.Endpoint)[:secret_key_base]
    jwt = payload["token"] |> token |> with_signer(hs256(secret))

    case verify!(jwt) do
      {:ok, claims} -> claims["user"]["id"] == user_id
      {:error, _} -> false
    end
  end
end
