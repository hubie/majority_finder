defmodule MajorityFinderWeb.VoterLive do
  use Phoenix.LiveView

  alias MajorityFinder.Presence
  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @metricsTopic inspect(MajorityFinder.Metrics)
  @questionTopic "questions"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @questionTopic)
  end

  @initial_store %{
    question: %{},
    online_user_count: 0,
    session_id: nil,
    voter_state: :new
  }

  def mount(_params, %{"session_uuid" => key}, socket) do
    if connected?(socket), do: subscribe()

    Presence.track(
      self(),
      @metricsTopic,
      socket.id,
      %{}
    )

    {:ok, assign(socket, %{@initial_store | question: Results.get_current_question(), session_id: key, voter_state: Results.get_voter_state(key)})}
  end

  def handle_info({Results, :voting_closed}, state) do
    new_state = state
      |> update(:question, fn _ -> %{} end)
      |> update(:voter_state, fn _ -> :voting_closed end)

    {:noreply, new_state}
  end

  def handle_info({Results, %{new_question: question, voter_state: new_voter_state}}, state) do
    new_state = state
      |> update(:question, fn _ -> question end)
      |> update(:voter_state, fn _ -> new_voter_state end)

    {:noreply, new_state}
  end

  def handle_event("submitAnswer", %{"value" => value}, socket) do
    vote = String.to_atom(value)
    %{voter_state: new_voter_state} = Results.vote_cast(socket.assigns.session_id, vote)
    new_socket = socket
      |> update(:voter_state, fn _ -> new_voter_state end)

    {:noreply, new_socket}
  end

  def render(assigns) do
    ~L"""
    <%= live_component(
      @socket,
      MajorityFinderWeb.Components.TitleComponent
      )
    %>
    <div>
      <h1> <%=
        case @voter_state do
          :new -> "Welcome!"
          :voting_closed -> "Standby..."
          :voted -> "Thanks for voting!"
          :new_question ->
            question = @question
            live_component(@socket, MajorityFinderWeb.Components.QuestionComponent, question: question)
          _ -> "Unknown state: #{@voter_state}"
        end
      %>
    </div>
    """
  end

end
