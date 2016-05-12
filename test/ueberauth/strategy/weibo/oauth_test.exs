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

  test "get_access_token with error from new token" do
    access_token = %OAuth2.AccessToken{access_token: "token"}
    token = access_token |> get_access_token("", %{"error" => ""})
    assert token.access_token == "token"
  end

  test "get_access_token with params in `other_params`", %{client: client} do
    access_token = OAuth2.AccessToken.new(%{
      "{\"access_token\":\"token\"}" => nil
    }, client)
    token = access_token |> get_access_token(nil, nil)
    assert token.access_token == "token"
  end
end
