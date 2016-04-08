# Überauth Weibo

> Weibo OAuth2 strategy for Überauth.

## Installation

  1. Setup your application at [Weibo Open Platform](http://open.weibo.com).

  2. Add `:ueberauth_weibo` to your list of dependencies in `mix.exs`:

        def deps do
          [{:ueberauth_weibo, "~> 0.0.1"}]
        end

  3. Add the strategy to your application:

        def application do
          [applications: [:ueberauth_weibo]]
        end

  4. Add Weibo to your Überauth configuration:

      ```elixir
      config :ueberauth, Ueberauth,
        providers: [
          weibo: {Ueberauth.Strategy.Weibo, []}
        ]
      ```

  5.  Update your provider configuration:

      ```elixir
      config :ueberauth, Ueberauth.Strategy.Weibo.OAuth,
        client_id: System.get_env("WEIBO_CLIENT_ID"),
        client_secret: System.get_env("WEIBO_CLIENT_SECRET")
      ```

  6.  Include the Überauth plug in your controller:

      ```elixir
      defmodule MyApp.AuthController do
        use MyApp.Web, :controller
        plug Ueberauth
        ...
      end
      ```

  7.  Create the request and callback routes if you haven't already:

      ```elixir
      scope "/auth", MyApp do
        pipe_through :browser

        get "/:provider", AuthController, :request
        get "/:provider/callback", AuthController, :callback
      end
      ```

  8. You controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

  For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.


## Calling

    Depending on the configured url you can initial the request through:

        /auth/weibo

## License

  Please see [LICENSE](https://github.com/he9qi/ueberauth_weibo/blob/master/LICENSE) for licensing details.
