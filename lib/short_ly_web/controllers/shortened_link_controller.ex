defmodule ShortLyWeb.ShortenedLinkController do
  use ShortLyWeb, :controller

  alias ShortLy.{Shortener}

  def new(conn, _params) do
    changeset = Shortener.new_shortened_link()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shortened_link" => params}) do
    host = conn |> get_host()

    case Shortener.create_shortened_link(params) do
      {:ok, shortened_link} ->
        conn
        |> put_flash(
          :sucess,
          "Url generated successfully. Copy the code: #{host}/#{shortened_link.internal_link}"
        )
        |> redirect(to: Routes.shortened_link_path(conn, :index))

      {:already_converted, shortened_link} ->
        conn
        |> put_flash(
          :info,
          "Already exists. Copy the code: #{host}/#{shortened_link.internal_link}"
        )
        |> redirect(to: Routes.shortened_link_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :insert)
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"internal_link" => internal_link}) do
    shortened_link = internal_link |> Shortener.get_shortened_link_by_internal_link() || %{}

    shortened_link
    |> Map.get(:referenced_link)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "Link not founded, try again: #{internal_link}")
        |> redirect(to: Routes.shortened_link_path(conn, :index))

      referenced_link ->
        Shortener.increase_times_used(shortened_link)
        redirect(conn, external: referenced_link)
    end
  end

  def index(conn, _params) do
    shortened_links = Shortener.list_shortened_links()
    render(conn, "index.html", shortened_links: shortened_links)
  end

  defp get_host(conn), do: conn.req_headers |> Enum.into(%{}) |> Map.get("host")
end
