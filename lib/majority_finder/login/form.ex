defmodule MajorityFinder.Login.Form do
  alias MajorityFinder.User

  def get_user_by_code(user) do
    user
    |> User.get_user()
  end
end
