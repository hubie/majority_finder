defmodule MajorityFinderWeb.Results do
  use Phoenix.LiveView

  alias MajorityFinderWeb.Host
  alias MajorityFinderWeb.Voter

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: MajorityFinderWeb.Voter.subscribe()
    if connected?(socket), do: MajorityFinderWeb.Host.subscribe()
    {:ok, assign(socket, :state, %{results: %{}})}
  end


  def handle_info({Host, %{new_question: question}}, state) do
    new_state = update(state, :state, &Map.put(&1, :results, %{}))
    {:noreply, new_state}
  end

  def handle_info({Host, :close}, state) do
    {:noreply, update(state, :state, &(Map.put(&1, :results, %{})))}
  end


  def handle_info({Voter, %{vote: vote}}, state) do
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
