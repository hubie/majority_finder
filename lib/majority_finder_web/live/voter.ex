defmodule MajorityFinderWeb.Voter do
  use Phoenix.LiveView

  @results "results"

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
  end

  def mount(_params, _session, socket) do
    MajorityFinderWeb.Endpoint.subscribe(@results) # subscribe to the channel
    {:ok, assign(socket, :state, %{answer: :undef})}
  end

  def handle_event("yes", _, socket) do
    new_state = update(socket, :state, &(Map.put(&1,:answer,:yes)))
    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @topic, {__MODULE__, %{vote: :yes}})

    {:noreply, new_state}
  end

  def handle_event("no", _, socket) do
    new_state = update(socket, :state, &(Map.put(&1,:answer,:no)))
    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @topic, {__MODULE__, %{vote: :no}})

    {:noreply, new_state}
  end

  def handle_event(:vote_submitted, _, socket) do
    inspect socket
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h1>Last Answer is: <%= @state.answer %></h1>
      <button phx-click="yes">Yes</button>
      <button phx-click="no">No</button>
    </div>
    """
  end
end