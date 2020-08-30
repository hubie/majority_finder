defmodule MajorityFinderWeb.Live.Helper do
  def signing_salt do
    MajorityFinderWeb.Endpoint.config(:live_view)[:signing_salt] ||
      raise MajorityFinderWeb.AuthenticationError, message: "missing signing_salt"
  end
end
