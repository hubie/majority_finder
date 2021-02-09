defmodule MajorityFinderWeb.StatsLive do
  use Phoenix.LiveView

  alias MajorityFinderWeb.StatsController

  @topic inspect(__MODULE__)
  @statsTopic "stats"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @statsTopic)
  end

  @initial_store %{
    player_stats: %{}
  }


  def mount(params, _session, socket) do
    if connected?(socket), do: subscribe()

    {:ok, assign(socket, @initial_store)}
  end

  def handle_info({StatsController, %{update_stats: stats}}, state) do
    IO.inspect(["GOTEM", stats])
    new_state = state
      |> update(:player_stats, fn _ -> stats end)

    # IO.inspect(["GOTEM", stats])
    {:noreply, new_state}
  end



  def render(assigns) do
    ~L"""
      <div class="statscontainer">
        <table>
          <%= for player <- @player_stats || [] do %>
            <tr>
              <td class="player-stat name"><%= player["Name"] %></td> 
              <td class="player-stat armor-class"><%= player["Armor Class"] %></td> 
              <td class="player-stat hit-points">HP <%= player["Hit Points"] %></td>
              <td class="player-stat class"><%= player["Class"] %></td> 
              <td class="player-stat resource"><%= player["Resource"] %></td> 

            </tr>
          <% end %>
        </table>
      </div>
    """
  end
end