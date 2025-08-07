defmodule AcrogoopWeb.Router do
  use AcrogoopWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AcrogoopWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :ensure_session_id
  end

  defp ensure_session_id(conn, _opts) do
    case get_session(conn, "session_id") do
      nil ->
        session_id = :crypto.strong_rand_bytes(16) |> Base.encode64()
        put_session(conn, "session_id", session_id)
      _ ->
        conn
    end
  end

  scope "/", AcrogoopWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/game/:code", GameLive, :show
  end
end
