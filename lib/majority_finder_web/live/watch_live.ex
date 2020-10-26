defmodule MajorityFinderWeb.WatchLive do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @initial_store %{
    key: nil,
    vote_here: :instructions,
    video_player: :webrtc
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


  def mount(_params, %{"session_uuid" => key} = _session, socket) do
    {:ok, assign(socket, %{@initial_store |
      key: key
      })
    }
  end

  def render(assigns) do
    ~L"""
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha256-4+XzXVhsDmqanXGHaHvgh1gMQKX40OUvDEBTu8JcmNs=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/js-cookie@2.2.1/src/js.cookie.js" integrity="sha256-P8jY+MCe6X2cjNSmF4rQvZIanL5VwUUT4MBnOMncjRU=" crossorigin="anonymous"></script>
    <script type="text/javascript" src="https://webrtchacks.github.io/adapter/adapter-latest.js"></script>

    <%= live_component(
      @socket,
      MajorityFinderWeb.Components.TitleComponent
      )
    %>
    <div display="flex">
      <div class="videopanel">
        <%= case @video_player do %>
          <% :legacy -> %>
            <div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/472033897" frameborder="0" allow="autoplay; fullscreen" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;"></iframe></div>
            <div>
              <button phx-click="video_player" value="webrtc">Low Latency Player</button>
            </div>
          <% # WebRTC player & default %>
          <% _ -> %>
            <video id="player-video" width="100%" autoplay playsinline controls></video>
            <div>
              <button phx-click="video_player" value="legacy">Legacy Player (High Latency)</div>
            </div>
        <% end %>
      </div>

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
    </div>
    """
  end
end