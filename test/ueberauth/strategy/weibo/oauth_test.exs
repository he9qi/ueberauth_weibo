defmodule Ueberauth.Strategy.Weibo.OAuthTest do
  use ExUnit.Case

  import Ueberauth.Strategy.Weibo.OAuth

  setup do
    {:ok, %{client: client}}
  end

  test "parses correct user info", %{client: client} do
    assert client.client_id == "appid"
    assert client.client_secret == "secret"
    assert client.redirect_uri == "/callback"
    assert client.authorize_url == "/oauth2/authorize"
    assert client.token_url == "/oauth2/access_token"
    assert client.site == "https://api.weibo.com"
  end
end
