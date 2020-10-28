defmodule MajorityFinderWeb.VoterLive do
  use Phoenix.LiveView

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
    embed: false,
    question: %{},
    online_user_count: 0,
    session_id: nil,
    voter_state: :new,
    show_mode: nil
  }

  def mount(params, %{"session_uuid" => key} = session, socket) do
    if connected?(socket), do: subscribe()

    Presence.track(
      self(),
      @metricsTopic,
      socket.id,
      %{}
    )
    embed = Access.get(params, "embed", "false") == "true"

    {:ok, assign(socket, %{@initial_store |
      embed: embed,
      question: Results.get_current_question(),
      session_id: key,
      voter_state: Results.get_voter_state(key),
      show_mode: Results.get_current_show_mode
      })
    }
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
      <h1>
      <%=
        case @show_mode do %>
        <%= :preshow -> %>
          <h2>You're in the right place!</h2>
          <p/>
          The Majority is an interactive show.  You will be asked for your thoughts on a number of topics.  You will be prompted – right here! – to give your answer.
          <p/>
          The Majority opens this Friday, October 30th and runs though November 14th.<br/>
          Visit <a href="http://www.theatreb.org/the-majority">Theatre B's Website</a> for tickets and more information.

        <%= :show -> %>
          <%= case @voter_state do %>
            <%= :voting_closed -> %>
              <span class="ellipsis-anim"><span>.</span><span>.</span><span>.</span>
            <%= :voted -> %>
                Thank you for voting.<br/>
                The Majority opens this Friday, October 30th and runs though November 14th.<br/>
                Visit <a href="http://www.theatreb.org/the-majority">Theatre B's Website</a> for tickets and more information.
            <%= :new_question -> %>
              <%= question = @question
                live_component(@socket, MajorityFinderWeb.Components.QuestionComponent, question: question) %>
              <%= _ -> %>
                <%= "Unknown state: #{@voter_state}" %>
            <% end %>
          <%= :postshow -> %>
              We hope you enjoyed this little preview!<br/>
              The Majority opens this Friday, October 30th and runs though November 14th.<br/>
              Visit <a href="http://www.theatreb.org/the-majority">Theatre B's Website</a> for tickets and more information.
          <%= _ ->  %>
          <%= "Unknown show state #{@show_mode}" %>
        <% end %>
    </div>
    """
  end

end
