defmodule MajorityFinderWeb.EmbeddedVoteLive do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @initial_store %{
    key: nil,
    vote_here: :instructions,
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

  def mount(params, %{"session_uuid" => key} = _session, socket) do
    {:ok, assign(socket, %{@initial_store |
      key: key
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
                It's easy!
                <ol>
                  <li> Grab a smart phone, tablet, or another computer
                  <li> Go to <a target="_parent" href="/vote">themajority.live/vote</a>
                  <li> Enter your access code
                </ol>
                When it's time to vote, the question and choices will appear on the screen.  Then it's your turn!
              </div>
              <br/>
              <div class="voteinstructions votehere">
                If you don't have access to another device, you can also <a href="#" phx-click="voteHere" phx-value-value="true" class="voteinstructions votehere link">Vote by clicking Here</a>
              </div>
              <!--
              <div class="voteinstructions close">
                <button phx-click="voteHere" value="close" class="voteinstructions close">Close</button>
              </div>
              -->
            </div>
        <% end %>
      </div>
    """
  end
end