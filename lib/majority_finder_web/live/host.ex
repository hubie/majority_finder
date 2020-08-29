defmodule MajorityFinderWeb.Host do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @resultsTopic "results"
  @metricsTopic "metrics"

  @initial_store %{
    results: nil,
    online_voters: 0
  }

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @resultsTopic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @metricsTopic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe()
    results = Results.get_current_results()
    voter_count = Results.get_current_voter_count()
    state = %{@initial_store | results: results, online_voters: voter_count}
    {:ok, assign(socket, :state, state)}
  end

  def handle_info({Results, %{results: results}}, state) do
    {:noreply, update(state, :state, &Map.put(&1, :results, results))}
  end

  def handle_info({Results, %{online_voters: user_count}}, state) do
    IO.inspect(["GOT UPDATE: ", user_count])
    {:noreply, update(state, :state, &Map.put(&1, :online_voters, user_count))}
  end

  def handle_event("submit_question", _, socket) do
    Results.new_question(fetch_question(:something))
    {:noreply, socket}
  end

  defp fetch_question(_which_question) do
    %{question: "Do you like it?", answers: [:yes, :no, :maybe]}
  end

  def handle_event("close", _, socket) do
    new_state = update(socket, :state, &Map.put(&1, :results, %{}))
    new_state2 = update(new_state, :state, &Map.put(&1, :question_state, :closed))

    Results.reset_results()

    {:noreply, new_state2}
  end

  def render(assigns) do
    ~L"""
    <div>
      <%= for {value, result} <- @state.results do %>
        <h1><%= value %>: <%= result %></h1>
      <% end %>
    </div>
    <div>
      <button phx-click="submit_question">Submit Question</button>
      <button phx-click="close">Close Voting</button>
    </div>
    <div>Online users: <%= @state.online_voters %></div>
    """
  end
end
