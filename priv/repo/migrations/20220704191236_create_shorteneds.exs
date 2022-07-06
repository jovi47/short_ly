defmodule ShortLy.Repo.Migrations.CreateShorteneds do
  use Ecto.Migration

  def change do
    create table(:shortened_links) do
      add :internal_link, :string, size: 8, null: false
      add :referenced_link, :string, null: false
      add :used, :integer, null: false, default: 0
      add :converted, :integer, null: false, default: 0

      timestamps(updated_at: false)
    end

    create unique_index(:shortened_links, [:internal_link])
    create unique_index(:shortened_links, [:referenced_link])
  end
end
