defmodule AcrogoopWeb.ErrorHTML do
  def error(conn, _assigns) do
    case conn.status do
      404 -> "Not Found"
      500 -> "Internal Server Error"
      _ -> "Error"
    end
  end
end
