defmodule ShortLy.Shortener do
  import Ecto.Query, warn: false
  alias ShortLy.{Repo, Shortener.ShortenedLink}

  def get_shortened_link_by_internal_link(internal_link),
    do: Repo.one(from sl in ShortenedLink, where: sl.internal_link == ^internal_link)

  def get_shortened_link_by_referenced_link(referenced_link),
    do: Repo.one(from sl in ShortenedLink, where: sl.referenced_link == ^referenced_link)

  def create_shortened_link(params \\ %{}) do
    params
    |> ShortenedLink.changeset()
    |> ShortenedLink.put_internal_link()
    |> ShortenedLink.validate_referenced_link()
    |> handle_create_shortened_link()
  end

  defp handle_create_shortened_link(
         %Ecto.Changeset{changes: %{referenced_link: referenced_link}} = changeset
       ) do
    case get_shortened_link_by_referenced_link(referenced_link) do
      nil -> changeset |> Repo.insert(returning: true)
      shortened_link -> shortened_link |> increase_times_converted()
    end
  end

  defp handle_create_shortened_link(changeset), do: {:error, changeset}

  defp increase_times_converted(shortened_link) do
    {1, [%ShortenedLink{converted: converted}]} =
      from(sl in ShortenedLink, where: sl.id == ^shortened_link.id, select: [:converted])
      |> Repo.update_all(inc: [converted: 1])

    {:already_converted, put_in(shortened_link.converted, converted)}
  end

  def increase_times_used(shortened_link) do
    {1, [%ShortenedLink{used: used}]} =
      from(sl in ShortenedLink, where: sl.id == ^shortened_link.id, select: [:used])
      |> Repo.update_all(inc: [used: 1])

    {:already_converted, put_in(shortened_link.used, used)}
  end

  def new_shortened_link(params \\ %{}), do: params |> ShortenedLink.changeset()

  def list_shortened_links, do: Repo.all(ShortenedLink)
end
