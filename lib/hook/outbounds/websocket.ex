defmodule Accent.Hook.Outbounds.Websocket do
  @moduledoc false
  use Oban.Worker, queue: :hook

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    args
    |> Accent.Hook.Context.from_worker()
    |> merge_user()
    |> broadcast_event()
  end

  defp broadcast_event(event) do
    Accent.Endpoint.broadcast("projects:" <> event.project.id, event.event, event.payload)
  end

  defp merge_user(%{user: user, payload: payload} = event) do
    %{
      event
      | payload: %{
          "payload" => payload,
          "user" => %{
            "id" => user.id,
            "name" => Accent.User.name_with_fallback(user)
          }
        }
    }
  end
end
