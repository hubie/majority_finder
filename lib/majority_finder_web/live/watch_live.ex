defmodule MajorityFinderWeb.WatchLive do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @initial_store %{
    key: nil,
    vote_here: false
  }

  def handle_event("voteHere", %{} = _value, socket) do
    new_socket = socket
      |> update(:vote_here, fn _ -> true end)

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

    <%= live_component(
      @socket,
      MajorityFinderWeb.Components.TitleComponent
      )
    %>
    <div display="flex">
      <div phx-update="ignore" class="videopanel">
        <div phx-update="ignore" class="theoplayer-container video-js theoplayer-skin vjs-16-9"></div>
          <script phx-update="ignore">
            var element = document.querySelector(".theoplayer-container");
            var player = new THEOplayer.Player(element, {
                libraryLocation: "https://cdn.myth.theoplayer.com/1230daef-f515-4df9-b106-eacd30822514"
            });

            player.source = {
                sources: [{
                    "src": "https://5f85d4bfe11f1.streamlock.net:443/live/themajority/playlist.m3u8",
                    // "src": "https://54.70.90.240:443/live/themajority/playlist.m3u8",
                    // "src": "https://54.70.90.240/[application]/[application-instance]/[stream-name]/playlist.m3u8"
                    // "src": "https://5f85d4bfe11f1.streamlock.net:1935/majority/themajority/playlist.m3u8",
                    "type": "application/x-mpegurl",
                    "lowLatency": true
                }]

            };

            player.autoplay = false;
            player.preload = 'auto';
          </script>
      </div>
      <%= if @vote_here do %>
        <div class="votepanel">
          <iframe class="embeddedvote" src="/vote?embed=true">
        </div>
      <% else %>
        <div class="voteinstructions">
          <div class="voteinstructions title">
            Register to vote!
          </div>
          <div class="voteinstructions instructions">
            Use your cell phone, other mobile device, or another computer, go to <a href="/vote">theatreb.org/vote</a> and enter your login code
          </div>
          <div class="voteinstructions votehere">
            If you don't have access to another device, you can also <button phx-click="voteHere" class="voteinstructions votehere">Vote Here</button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end