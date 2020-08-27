defmodule MajorityFinderWeb.Voter do
  use Phoenix.LiveView

  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @questionTopic "questions"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @questionTopic)
  end

  @initial_store %{
    answer: nil,
    question: %{},
  }

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe()

    state = Map.put(@initial_store, :question, Results.get_current_question())

    {:ok, assign(socket, :state, state)}
  end

  def handle_info({Results, :voting_closed}, state) do
    new_state = update(state, :state, &(Map.put(&1, :answer, nil)))
      |> update(:state, &(Map.put(&1, :question, %{})))
    {:noreply, new_state}
  end

  def handle_info({Results, %{new_question: question}}, state) do
    {:noreply, update(state, :state, &(Map.put(&1, :question, question)))}
  end


  def handle_event("submitAnswer", %{"value"=> value}, socket) do
    vote = String.to_atom(value)
    Results.vote_cast(vote)
    {:noreply, update(socket, :state, &(Map.put(&1,:answer,vote)))}
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