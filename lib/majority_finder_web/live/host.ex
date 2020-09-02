defmodule MajorityFinderWeb.Host do
  use Phoenix.LiveView
  import Phoenix.HTML.Form

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
    {:noreply, update(state, :state, &Map.put(&1, :online_voters, user_count))}
  end

  def handle_event("select_question", params, socket) do
    IO.inspect(params, label: "SELECT QUESTION")
    {:noreply, socket}
  end

  def handle_event("validate", %{"question_select" => _selected_index}, socket) do
    changeset = %{}
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", _, socket) do
    changeset = %{}
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"question_select" => %{"question" => question_index}}, socket) do
    %{"question" => question, "answers" => answers} =
      questions() |> Enum.at(String.to_integer(question_index))

    Results.new_question(%{question: question, answers: answers |> Enum.map(&String.to_atom(&1))})
    {:noreply, socket}
  end

  def handle_event("close", _, socket) do
    new_state =
      socket
      |> update(:state, &Map.put(&1, :results, %{}))
      |> update(:state, &Map.put(&1, :question_state, :closed))

    Results.reset_results()

    {:noreply, socket}
  end

  defp questions() do
    Jason.decode!(~s(
      [
        {
          "question": "This community understands and accepts the voting system for the show tonight.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community wishes to ban all latecomers.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community is male.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community is white.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community is pro-choice.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes in the death penalty. This community believes in God.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes in absolute freedom of speech.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes they can make a difference.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes that Scotland should be an independent country.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community would push the lever.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community would push the fat man to his death.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community would push the lever.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community would push the lever \(and save the five Nazi lives\).",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes that we should punish the minority by not giving them a toilet break.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes that the UK should leave the EU.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes the letter should be read.",
          "answers": ["Yes", "No"]
        },
        {
          "question": "This community believes that attacking someone for holding an opin- ion is a helpful thing to do.",
          "answers": ["Yes", "No"]
        }
      ]
      ))
  end

  def render(assigns) do
    ~L"""
    <div>
      <%= f = form_for :question_select, "#", [phx_change: :validate, phx_submit: :save] %>
        <%= select f, :question, Enum.map(Enum.with_index(questions()), fn {%{"question" => q}, i} -> {"Q#{i}: #{q}", i} end), [class: "host question-select", size: "6"] %>
        <div>
          <%= submit "Submit Question" %>
        </div>
      </form>
      <button class="host close-voting button button-outline" phx-click="close">Close Voting</button>
    </div>
    <div>
    </div>
    <div class="host open-question live-results">
      <div class="host open-question question">
        <h3>Live results:</h3>
      </div>
      <%= for {value, result} <- @state.results do %>
        <div class="host open-question answers"><%= value %>: <%= result %></div>
      <% end %>
    </div>
    <div class="host metrics">
      <div class="host metrics online-users">Online users: <%= @state.online_voters %></div>
    </div>
    """
  end
end
