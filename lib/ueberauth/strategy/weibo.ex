defmodule Ueberauth.Strategy.Weibo do
  @moduledoc """
  Provides an Ueberauth strategy for authenticating with Weibo.

  ### Setup

  Create an application in Weib for you to use.

  Register a new application at: [weibo open platform page](http://open.weibo.com/apps)
  and get the `client_id` and `client_secret`.

  Include the provider in your configuration for Ueberauth

      config :ueberauth, Ueberauth,
        providers: [
          weibo: { Ueberauth.Strategy.Weibo, [] }
        ]

  Then include the configuration for weibo.

      config :ueberauth, Ueberauth.Strategy.Weibo.OAuth,
        client_id: System.get_env("WEIBO_CLIENT_ID"),
        client_secret: System.get_env("WEIBO_CLIENT_SECRET")

  If you haven't already, create a pipeline and setup routes for your callback handler

      pipeline :auth do
        Ueberauth.plug "/auth"
      end

      scope "/auth" do
        pipe_through [:browser, :auth]

        get "/:provider/callback", AuthController, :callback
      end


  Create an endpoint for the callback where you will handle the `Ueberauth.Auth` struct

      defmodule MyApp.AuthController do
        use MyApp.Web, :controller

        def callback_phase(%{ assigns: %{ ueberauth_failure: fails } } = conn, _params) do
          # do things with the failure
        end

        def callback_phase(%{ assigns: %{ ueberauth_auth: auth } } = conn, params) do
          # do things with the auth
        end
      end
  """
  use Ueberauth.Strategy, oauth2_module: Ueberauth.Strategy.Weibo.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles the initial redirect to the weibo authentication page.

  request url:

      "/auth/weibo"

  You can also include a `state` param that weibo will return to you.
  """
  def handle_request!(conn) do
    opts = []
    if conn.params["state"], do: opts = Keyword.put(opts, :state, conn.params["state"])
    opts = Keyword.put(opts, :redirect_uri, callback_url(conn))
    module = option(conn, :oauth2_module)

    redirect!(conn, apply(module, :authorize_url!, [opts]))
  end

  @doc """
  Handles the callback from Weibo. When there is a failure from Weibo the failure is included in the
  `ueberauth_failure` struct. Otherwise the information returned from Weibo is returned in the `Ueberauth.Auth` struct.
  """
  def handle_callback!(%Plug.Conn{ params: %{ "code" => code } } = conn) do
    module = option(conn, :oauth2_module)
    token = apply(module, :get_token!, [[code: code]])

    if token.access_token == nil do
      set_errors!(conn, [error(token.other_params["error"], token.other_params["error_description"])])
    else
      fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc """
  Cleans up the private area of the connection used for passing the raw Weibo response around during the callback.
  """
  def handle_cleanup!(conn) do
    conn
    |> put_private(:weibo_user, nil)
    |> put_private(:weibo_token, nil)
  end

  @doc """
  Fetches the uid field from the Weibo response.
  """
  def uid(conn) do
    conn.private.weibo_user["idstr"]
  end

  @doc """
  Includes the credentials from the Weibo response.
  """
  def credentials(conn) do
    token = conn.private.weibo_token
    scopes = (token.other_params["scope"] || "")
    |> String.split(",")

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: scopes
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.weibo_user

    %Info{
      name: user["name"],
      nickname: user["screen_name"],
      location: user["location"],
      description: user["description"],
      image: user_image(conn),
      urls: %{
        blog: user["url"],
        weibo: user_weibo(conn)
      }
    }
  end

  def user_weibo(conn) do
    user   = conn.private.weibo_user

    domain = user['domain']
    uid    = user['idstr']
    if user['domain'], do: "http://weibo.com/#{domain}", else: "http://weibo.com/u/#{uid}"
  end

  def user_image(conn) do
    user = conn.private.weibo_user

    user["avatar_hd"] || user["avatar_large"] || user["profile_image_url"]
  end

  @doc """
  Stores the raw information (including the token) obtained from the Weibo callback.
  """
  def extra(conn) do
    %Extra {
      raw_info: %{
        token: conn.private.weibo_token,
        user: conn.private.weibo_user
      }
    }
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :weibo_token, token)
    uid = uid(conn)
    access_token = token.access_token
    fetch_user_url = "/user/2/users/show.json?uid=#{uid}&access_token=#{access_token}"
    case OAuth2.AccessToken.get(token, fetch_user_url) do
      { :ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      { :ok, %OAuth2.Response{status_code: status_code, body: user} } when status_code in 200..399 ->
        put_private(conn, :weibo_user, user)
      { :error, %OAuth2.Error{reason: reason} } ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp option(conn, key) do
    Dict.get(options(conn), key, Dict.get(default_options, key))
  end
end
