defmodule AppWeb.Plugs.ErrorRenderer do
  @behaviour Plug

  alias Plug.Conn
  alias OpenApiSpex.OpenApi

  @impl Plug
  def init(errors), do: errors

  @impl Plug
  def call(conn, errors) when is_list(errors) do
    response = %{
      errors: Enum.map(errors, &render_error/1)
    }

    json =
      response
      |> Map.put(:success, false)
      |> OpenApi.json_encoder().encode!()

    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(400, json)
  end

  defp render_error(error) do
    pointer = OpenApiSpex.path_to_string(error)

    %{
      title: "Invalid value",
      source: %{
        pointer: pointer
      },
      detail: to_string(error)
    }
  end
end
