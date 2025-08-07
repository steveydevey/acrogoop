defmodule AcrogoopWeb.ErrorJSON do
  def error(conn, _assigns) do
    %{errors: %{detail: error_message(conn.status)}}
  end

  defp error_message(404), do: "Not Found"
  defp error_message(500), do: "Internal Server Error"
  defp error_message(_), do: "Error"
end
