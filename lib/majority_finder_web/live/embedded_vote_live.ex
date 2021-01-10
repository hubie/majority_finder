defmodule MajorityFinderWeb.EmbeddedVoteLive do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @initial_store %{
    key: nil,
    vote_here: :instructions,
    show_mode: nil,
    message: nil,
  }
  @showTopic "showControl"

  def handle_event("voteHere", %{"value" => voteType} = _value, socket) do
    new_socket = socket
      |> update(:vote_here, fn _ ->
        case voteType do
          "true" -> true
          "close" -> :close
          _ -> :instructions
      end end)

    {:noreply, new_socket}
  end

  def handle_info({Results, %{show_mode: mode}}, state) do
    new_state = state
      |> update(:show_mode, fn _ -> mode end)

    {:noreply, new_state}
  end

  def handle_info({Results, %{message: message}}, state) do
    IO.inspect(["NEW MESSAGE", message])
    new_state = state
      |> update(:message, fn _ -> message end)

    {:noreply, new_state}
  end


  def mount(params, %{"session_uuid" => key} = _session, socket) do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @showTopic)
    %{show_mode: show_mode, message: message} = GenServer.call(Results, :get_show_state)
    IO.inspect(["LOL", show_mode, message])

    {:ok, assign(socket, %{@initial_store |
      key: key,
      show_mode: show_mode,
      message: message
      })
    }
  end

  def render(assigns) do
    Phoenix.View.render(MajorityFinderWeb.Voter.VoterLive, "embedded_vote_instructions.html", assigns)
  end
end