defmodule ShortLy.Shortener.ShortenedLink do
  alias ShortLy.Shortener.{Helper}
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoFields
  @required_params [:referenced_link]

  schema "shortened_links" do
    field :converted, :integer
    field :used, :integer
    field :internal_link, :string
    field :referenced_link, :string

    timestamps(updated_at: false)
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:converted, :used, :internal_link, :referenced_link])
    |> validate_required(@required_params)
  end

  def put_internal_link(changeset),
    do: changeset |> put_change(:internal_link, Helper.generate_internal_link())

  def validate_referenced_link(
        %Ecto.Changeset{changes: %{referenced_link: referenced_link}} = changeset
      ) do
    referenced_link
    |> Helper.validate_link()
    |> case do
      true ->
        changeset

      false ->
        changeset |> add_error(:referenced_link, "The link is invalid, please put the full URL")
    end
  end

  def validate_referenced_link(changeset), do: changeset
end
