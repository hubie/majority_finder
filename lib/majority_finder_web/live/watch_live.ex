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
      <div phx-update="ignore" class="videopanel">
        <div phx-update="ignore" id="play-video-container">
          <video id="player-video" width="100%" autoplay playsinline controls></video>
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