defmodule MajorityFinderWeb.LoginLive do
  use MajorityFinderWeb, :live_view
  alias MajorityFinderWeb.LayoutView
  import Phoenix.HTML.Form
  import MajorityFinderWeb.Live.Helper, only: [signing_salt: 0]

  alias MajorityFinder.User

  @impl true
  def render(assigns) do
    ~L"""
        <div class="login header">
          Welcome to the Slackies
        </div>
        <div class="login-box-container">
          <%= form_for :user, "#", [phx_submit: :save, autocomplete: "off", autocorrect: "off", autocapitalize: "off", spellcheck: "false"], fn f -> %>
            <fieldset class="flex flex-col md:w-full">

              <div>
                <label class="login access-code-label" for="form_email">Enter Access Code:</label>
                <%= text_input f, :validation_code, [class: "login password-box focus:border focus:border-b-0 rounded border", placeholder: "Access Code", aria_required: "true"] %>
                <%= submit "Submit" %>
              </div>
            </fieldset>
          <% end %>
        </div>
    </div>
    """
  end

  @impl true
  def mount(_params, %{"session_uuid" => key, "return_to" => return_to} = _session, socket) do
    current_user = %User{}
    {:ok, assign(socket, key: key, current_user: current_user, return_to: return_to)}
  end

  @impl true
  def mount(params, %{"session_uuid" => key} = _session, socket) do
    mount(params, %{"session_uuid" => key, "return_to" => "/"}, socket)
  end


  @impl true
  def handle_event(
        "save",
        %{"user" => %{"validation_code" => validation_code} = params},
        socket
      ) do
    if Map.get(params, "form_disabled", nil) != "true" do
      current_user =
        MajorityFinder.Login.Form.get_user_by_code(%User{validation_code: validation_code})
      send(self(), {:disable_form, current_user})
      {:noreply, assign(socket, current_user: current_user)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        {:disable_form, current_user},
        %{assigns: %{:key => key, :return_to => return_to}} = socket
      ) do
    case current_user do
      %User{id: user_id} ->
        insert_session_token(key, user_id)
        redirect = socket |> redirect(to: return_to)
        {:noreply, redirect}

      _ ->
        {:noreply, assign(socket, current_user: current_user)}
    end
  end

  def insert_session_token(key, user_id) do
    salt = signing_salt()
    token = Phoenix.Token.sign(MajorityFinderWeb.Endpoint, salt, user_id)
    :ets.insert(:auth_table, {:"#{key}", token})
  end
end
