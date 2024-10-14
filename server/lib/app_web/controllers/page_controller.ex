defmodule AppWeb.PageController do
  use AppWeb, :controller

  if Mix.env() == :prod do
    @index_html (Application.app_dir(:app) <> "/priv/static/index.html") |> File.read!()
  else
    @index_html "<p>Warning! This is API server!!!</p>"
  end

  def index(conn, %{"path" => ["api" | _]}) do
    send_resp(conn, 404, "Not Found")
  end

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, @index_html)
  end
end
