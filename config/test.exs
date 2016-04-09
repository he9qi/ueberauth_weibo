use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    weibo: { Ueberauth.Strategy.Weibo, [] }
  ]

config :ueberauth, Ueberauth.Strategy.Weibo.OAuth,
  client_id: "appid",
  client_secret: "secret",
  redirect_uri: "/callback"
