defmodule MajorityFinderWeb.EmbeddedVoteLive do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @initial_store %{
    key: nil,
    embedded_mode: nil,
    show_mode: nil,
    message: nil,
  }
  @showTopic "showControl"

  def mount(params, %{"session_uuid" => key} = _session, socket) do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @showTopic)
    %{show_mode: show_mode, message: message} = GenServer.call(Results, :get_show_state)

    {:ok, assign(socket, %{@initial_store |
      key: key,
      show_mode: show_mode,
      message: message,
      embedded_mode: Application.get_env(:majority_finder, MajorityFinderWeb.Endpoint, :instructions)[:default_embedded_vote_mode]
      })
    }
  end

  def handle_event("voteHere", %{"value" => voteType} = _value, socket) do
    new_socket = socket
      |> update(:embedded_mode, fn _ ->
        case voteType do
          "voteHere" -> :vote
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
    new_state = state
      |> update(:message, fn _ -> message end)

    {:noreply, new_state}
  end

  def render(assigns) do
    ~L"""
        <%= live_render(@socket, MajorityFinderWeb.VoterLive, id: "vote_panel", embedded_mode: true) %>
      """
  end
end