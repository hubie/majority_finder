defmodule MajorityFinderWeb.WatchLive do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @initial_store %{
    key: nil,
    vote_here: :instructions,
    video_player: :vimeo
  }

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

  def handle_event("video_player", %{"value" => type} = _value, socket) do
    new_socket = socket
      |> update(:video_player, fn _ -> String.to_atom(type) end)

    {:noreply, new_socket}
  end


  def mount(params, %{"session_uuid" => key} = _session, socket) do
    {:ok, assign(socket, %{@initial_store |
      key: key,
      video_player: String.to_atom(Map.get(params, "player", "vimeo"))
      })
    }
  end

  def render(assigns) do
    ~L"""
      <div>
        <%= case @vote_here do %>
          <% true -> %>
            <div class="votepanel">
              <iframe class="embeddedvote" src="/vote?embed=true">
            </div>
          <% :close -> %>
            <button phx-click="voteHere" value="instructions" class="voteinstructions show">Show Voting Instructions</button>
          <% # instructions, default %>
          <% _ -> %>
            <div class="voteinstructions">
              <div class="voteinstructions title">
                <i class="fas fa-vote-yea"></i>&nbsp;&nbsp;Register to vote!&nbsp;&nbsp;<i class="fas fa-vote-yea"></i>
              </div>
              <div class="voteinstructions instructions">
                Use your cell phone, other mobile device, or another computer, go to <a href="/vote">theatreb.org/vote</a> and enter your access code
              </div>
              <div class="voteinstructions votehere">
                If you don't have access to another device, you can also <button phx-click="voteHere" value="true" class="voteinstructions votehere">Vote Here</button>
              </div>
              <div class="voteinstructions close">
                <button phx-click="voteHere" value="close" class="voteinstructions close">Close</button>
              </div>
            </div>
        <% end %>
      </div>
    """
  end
end