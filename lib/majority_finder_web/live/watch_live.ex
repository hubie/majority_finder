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
      <div class="videopanel">
        <div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://vimeo.com/event/369120/embed/51a83aab7b" frameborder="0" allow="autoplay; fullscreen" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;"></iframe></div>
      </div>
      <%= if @vote_here do %>
        <div class="votepanel">
          <iframe class="embeddedvote" src="/vote?embed=true">
        </div>
      <%= else %>
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
      <%= end %>
    </div>
    """
  end
end