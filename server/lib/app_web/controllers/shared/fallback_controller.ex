defmodule AppWeb.Shared.FallbackController do
  @moduledoc false

  use AppWeb, :controller

  alias AppWeb.ErrorJSON
  alias Ecto.Changeset

  def call(conn, :ok) do
    conn
    |> put_status(:ok)
    |> json(%{success: true})
  end

  def call(conn, {:ok, data}) when is_map(data) do
    conn
    |> put_status(:ok)
    |> json(data)
  end

  def call(conn, {:error, status, %Changeset{} = changeset}) do
    conn
    |> put_status(status)
    |> put_view(ErrorJSON)
    |> render(:error, %{changeset: changeset})
  end

  def call(conn, {:error, status, message}) when is_binary(message) do
    conn
    |> put_status(status)
    |> put_view(ErrorJSON)
    |> render(:error, %{message: message})
  end
end
