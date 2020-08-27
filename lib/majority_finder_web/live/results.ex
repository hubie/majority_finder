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
