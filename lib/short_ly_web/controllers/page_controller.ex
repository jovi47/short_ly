defmodule ShortLyWeb.PageController do
  use ShortLyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
