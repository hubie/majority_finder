defmodule MajorityFinderWeb.Results do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @resultsTopic "results"


  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @resultsTopic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe()

    results = Results.get_current_results()
    {:ok, assign(socket, :state, %{results: results})}
  end


  def handle_info({Results, %{results: results}}, state) do
    {:noreply, update(state, :state, &(Map.put(&1, :results, results)))}
  end

  def handle_info({@topic, %{vote: vote}}, state) do
    current_value = Map.get(state.assigns.state.results, vote, 0)
    new_state = update(state, :state, &(put_in(&1,[:results, vote], current_value + 1)))

    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @topic, {__MODULE__, %{results: new_state.assigns.state.results}})

    {:noreply, new_state}
  end

  def render(assigns) do
    ~L"""
    <div>
      <%= for {value, result} <- @state.results do %>
        <h1><%= value %>: <%= result %></h1>
      <% end %>
    </div>
    """
  end
end
