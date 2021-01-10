defmodule MajorityFinderWeb.Host do
  use Phoenix.LiveView
  import Phoenix.HTML.Form

  alias MajorityFinder.Results
  alias MajorityFinder.Questions

  @topic inspect(__MODULE__)
  @resultsTopic "results"
  @metricsTopic "metrics"
  @showTopic "showControl"

  @initial_store %{
    questions: [],
    results: nil,
    online_voters: 0,
    show_mode: nil,
    message: nil,
  }

  def subscribe do
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @topic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @resultsTopic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @metricsTopic)
    Phoenix.PubSub.subscribe(MajorityFinder.PubSub, @showTopic)
  end

  def mount(_args, %{"user_id" => _user_id} = _session, socket) do
    if connected?(socket), do: subscribe()

    %{show_mode: show_mode, message: message} = GenServer.call(Results, :get_show_state)

    state = %{@initial_store | results: Results.get_current_results(),
                               online_voters: Results.get_current_voter_count(),
                               show_mode: show_mode,
                               message: message,
                               questions: GenServer.call(Questions, :get_questions)
                             }
    {:ok, assign(socket, state)}
  end

  def handle_info({Results, %{online_voters: user_count}}, state) do
    {:noreply, update(state, :online_voters, fn _ -> user_count end)}
  end

  def handle_info({Results, %{results: _r} = results}, state) do
    {:noreply, update(state, :results, fn _ -> results end)}
  end

  def handle_info({Results, %{show_mode: mode}}, state) do
    new_state = state
      |> update(:show_mode, fn _ -> mode end)

    {:noreply, new_state}
  end

  def handle_info({Results, %{message: _}}, state) do
    {:noreply, state}
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
    %{question: question, answers: answers, id: id} =
      socket.assigns.questions |> Enum.at(String.to_integer(question_index))

    Results.new_question(%{id: id})
    {:noreply, socket}
  end

  def handle_event("save", %{"custom_message" => %{"message" => message}}, socket) do
    Results.send_message(%{message: message})
    {:noreply, assign(socket, changeset: %{message: message})}
  end

  def handle_event("save", _, socket) do
    # no qustion selected
    {:noreply, socket}
  end

  def handle_event("close", _, socket) do
    Results.reset_results()
    {:noreply, socket}
  end

  def handle_event("showmode", %{"mode" => mode}, socket) do
    Results.set_show_mode(%{show_mode: String.to_atom(mode)})
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="content-body">
      <div>
        Mode:
        <% selected_class = "selected" %>
        <button class="host mode <%= if @show_mode == :preshow, do: selected_class %>" phx-click="showmode" phx-value-mode="preshow">Preshow</button>
        <button class="host mode <%= if @show_mode == :show, do: selected_class %>" phx-click="showmode" phx-value-mode="show">Show</button>
        <button class="host mode <%= if @show_mode == :postshow, do: selected_class %>" phx-click="showmode" phx-value-mode="postshow">Postshow</button>
      </div>
      <div>
        <%= f = form_for :question_select, "#", [phx_change: :validate, phx_submit: :save] %>
          <%= select f, :question, Enum.map(Enum.with_index(@questions), fn {%{question: q}, i} -> {"Q#{i+1}: #{q}", i} end), [class: "host question-select", size: "6"] %>
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
        <div>
          <%= get_in(@results, [:question, :question]) %>
        </div>
        <div>
          <%= for resultSet <- @results.results,
            {answer, result} <- resultSet do %>
            <div class="host open-question answers"><%= answer %>: <%= result %></div>
          <% end %>
        </div>
      </div>
      <div class="host metrics">
        <div class="host metrics online-users">Online users: <%= @online_voters %></div>
      </div>
      <div>
      <%= m = form_for :custom_message, "#", [phx_click: :validate, phx_submit: :save] %>
        <span>
          <%= text_input m, :message, [placeholder: "Custom Message", id: :custom_message] %>
          <%= submit "Send Message" %>
        </span>
      </form>
      </div>
    </div>
    """
  end
end
