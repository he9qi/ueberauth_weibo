defmodule SpecRouter do
  require Ueberauth
  use Plug.Router

  plug :fetch_query_params

  plug Ueberauth, base_path: "/auth"

  plug :match
  plug :dispatch

  get "/auth/weibo", do: send_resp(conn, 200, "weibo request")

  get "/auth/weibo/callback", do: send_resp(conn, 200, "weibo callback")
end

ExUnit.start()
