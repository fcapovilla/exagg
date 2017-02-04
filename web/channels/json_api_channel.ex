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
    # TODO: Validate user_id using session data from the payload
    true
  end
end
