defmodule Ueberauth.Strategy.WeiboTest do
  use ExUnit.Case

  use Plug.Test
  doctest Ueberauth.Strategy.Weibo

  @router SpecRouter.init([])

  test "request phase" do
    conn = :get
           |> conn("/auth/weibo")
           |> SpecRouter.call(@router)

    assert conn.resp_body == \
      "<html><body>You are being <a href=\"https://api.weibo.com/oauth2/authorize?client_id=appid&amp;redirect_uri=http%3A%2F%2Fwww.example.com%2Fauth%2Fweibo%2Fcallback&amp;response_type=code\">redirected</a>.</body></html>"
  end


  test "default callback phase" do
    # query = %{ code: "code_abc" } |> URI.encode_query
    #
    # conn = :get
    #        |> conn("/auth/weibo/callback?#{query}")
    #        |> SpecRouter.call(@router)
    #
    # assert conn.resp_body == "weibo callback"
    #
    # TODO: test weibo API get access token and user info
  end

  import Ueberauth.Strategy.Weibo
  alias Ueberauth.Auth.Info

  setup do
    {:ok, file} = "test/fixtures/weibo.json"
      |> Path.expand
      |> File.read

    json = file |> Poison.decode!

    {:ok, %{json: json}}
  end

  test "parses correct user info", %{json: json} do
    conn = %Plug.Conn{
      private: %{
        :weibo_user => json
      }
    }

    assert info(conn) == %Info{
        name: "zaku",
        nickname: "zaku",
        location: "北京 朝阳区",
        description: "人生五十年，乃如梦如幻；有生斯有死，壮士复何憾。",
        image: "http://tp1.sinaimg.cn/1404376560/180/0/1",
        urls: %{
          blog: "http://blog.sina.com.cn/zaku",
          weibo: "http://weibo.com/zaku"
        }
      }
  end
end
