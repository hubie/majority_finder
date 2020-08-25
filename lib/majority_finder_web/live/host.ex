defmodule MajorityFinderWeb.Host do
  use Phoenix.LiveView

  alias MajorityFinderWeb.Results
  alias MajorityFinderWeb.Voter

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: MajorityFinderWeb.Results.subscribe()
    # if connected?(socket), do: MajorityFinderWeb.Voter.subscribe()
    {:ok, assign(socket, :state, %{results: %{}})}
  end


  def handle_info({Results, %{results: results}}, state) do
    new_state = update(state, :state, &(Map.put(&1, :results, results)))
    {:noreply, new_state}
  end



  def handle_event("submit_question", _, socket) do
    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @topic, {__MODULE__, %{new_question: fetch_question(:something)}})
    new_state = update(socket, :state, &Map.put(&1, :question_state, :open))

    {:noreply, new_state}
  end

  def fetch_question(_which_question) do
    %{ question: "Do you like it?",
      answers: [:yes, :no, :maybe],
    }
  end


  def handle_event("close", _, socket) do
    new_state = update(socket, :state, &(Map.put(&1, :results, %{})))
    new_state2 = update(new_state, :state, &(Map.put(&1, :question_state, :closed)))

    Phoenix.PubSub.broadcast(MajorityFinder.PubSub, @topic, {__MODULE__, :close})

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
