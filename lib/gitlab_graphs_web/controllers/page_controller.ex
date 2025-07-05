defmodule GitlabGraphsWeb.PageController do
  use GitlabGraphsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
