defmodule MajorityFinderWeb.Components.VoteComponent do
  use Phoenix.LiveComponent

  alias MajorityFinder.Presence
  alias MajorityFinder.Results

  @topic inspect(__MODULE__)
  @metricsTopic inspect(MajorityFinder.Metrics)
  @questionTopic "questions"
  @showTopic "showControl"

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @questionTopic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @showTopic)
  end

  @initial_store %{
    question: %{},
    online_user_count: 0,
    session_id: nil,
    voter_state: :new,
    show_mode: nil
  }



  def mount(%{"id" => key} = session, socket) do
IO.inspect(["HI", session])
    if connected?(socket), do: subscribe()

    Presence.track(
      self(),
      @metricsTopic,
      socket.id,
      %{}
    )
    {:ok, assign(socket, %{@initial_store |
      question: Results.get_current_question(),
      session_id: key,
      voter_state: Results.get_voter_state(key),
      show_mode: Results.get_current_show_mode
      })
    }
  end

  def mount(session, socket) do
    IO.inspect(["HIIIII", session, socket])
    {:ok, assign(socket, @initial_store)}
  end

  def handle_info({Results, :voting_closed}, state) do
    new_state = state
      |> update(:question, fn _ -> %{} end)
      |> update(:voter_state, fn _ -> :voting_closed end)

    {:noreply, new_state}
  end

  def handle_info({Results, %{show_mode: mode}}, state) do
    new_state = state
      |> update(:show_mode, fn _ -> mode end)

    {:noreply, new_state}
  end

  def handle_info({Results, %{new_question: question, voter_state: new_voter_state}}, state) do
    new_state = state
      |> update(:question, fn _ -> question end)
      |> update(:voter_state, fn _ -> new_voter_state end)

    new_state = case Map.get(question, :time_limit) do
      nil -> push_event(new_state, "no_timer", %{})
      limit -> push_event(new_state, "new_timer", %{data: limit})
    end

    {:noreply, new_state}
  end

  def handle_event("submitAnswer", %{"value" => value}, socket) do
    %{voter_state: new_voter_state} = Results.vote_cast(socket.assigns.session_id, value)
    new_socket = socket
      |> update(:voter_state, fn _ -> new_voter_state end)

    {:noreply, new_socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h1> <%=
        case @show_mode do
          :preshow -> "HI!  Welcome!"
          :show ->
            case @voter_state do
              :preshow -> "Welcome!  The show will start shortly!"
              :voting_closed -> "Standby..."
              :voted -> "Thanks for voting!"
              :new_question ->
                question = @question
                live_component(@socket, MajorityFinderWeb.Components.QuestionComponent, question: question)
              _ -> "Unknown state: #{@voter_state}"
            end
          :postshow -> "Have a good night!"
          _ -> "Unknown show state #{@show_mode}"
        end
      %>
    </div>
    """
  end
end