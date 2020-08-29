defmodule MajorityFinder.Presence do
  use Phoenix.Presence,
    otp_app: :majority_finder,
    pubsub_server: MajorityFinder.PubSub
end