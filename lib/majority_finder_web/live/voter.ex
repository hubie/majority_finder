defmodule MajorityFinderWeb.Voter do
  use Phoenix.LiveView

  alias MajorityFinderWeb.Host

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: MajorityFinderWeb.Host.subscribe()
    {:ok, assign(socket, :state, %{answer: :undef})}
  end

  def handle_info({Host, :close}, state) do
    new_state = update(state, :state, &(Map.put(&1, :answer, :undef)))
      |> update(:state, &(Map.put(&1, :question, %{})))
    {:noreply, new_state}
  end

  def handle_info({Host, %{new_question: question}}, state) do
    {:noreply, update(state, :state, &(Map.put(&1, :question, question)))}
  end

  def handle_event("submitAnswer", value, socket) do
    new_state = update(socket, :state, &(Map.put(&1,:answer,:yes)))
    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @topic, {__MODULE__, %{vote: String.to_atom(value["value"])}})

    {:noreply, new_state}
  end

  def handle_event(:vote_submitted, _, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h1><%= get_in(@state, [:question, :question]) || "Waiting for a question..." %></h1>
      <%= for answers <- get_in(@state, [:question, :answers]) || [] do %>
        <button phx-click="submitAnswer" value="<%= answers %>"><%= answers %></button>
      <% end %>
    </div>
    """
  end
end