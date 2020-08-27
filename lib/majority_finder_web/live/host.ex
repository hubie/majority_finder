defmodule MajorityFinderWeb.Host do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @resultsTopic "results"
  @questionsTopic "questions"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @resultsTopic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @questionsTopic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe()
    results = Results.get_current_results()
    {:ok, assign(socket, :state, %{results: results})}
  end

  def handle_info({Results, %{results: results}}, state) do
    {:noreply, update(state, :state, &(Map.put(&1, :results, results)))}
  end

  def handle_info({Results, %{new_question: question}}, state) do
    {:noreply, update(state, :state, &(Map.put(&1, :question, question)))}
  end

  def handle_info({Results, :voting_closed}, state) do
    new_state = update(state, :state, &(Map.put(&1, :answer, nil)))
      |> update(:state, &(Map.put(&1, :question, %{})))
    {:noreply, new_state}
  end


  def handle_event("submit_question", _, socket) do
    Results.new_question(fetch_question(:something))
    {:noreply, socket}
  end


  def fetch_question(_which_question) do
    %{ question: "Do you like it?",
      answers: [:yes, :no, :maybe],
    }
  end


  def handle_event("close", _, socket) do
    new_state = update(socket, :state, &(Map.put(&1, :results, %{})))
    new_state2 = update(new_state, :state, &(Map.put(&1, :question_state, :closed)))

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
    """
  end
end
