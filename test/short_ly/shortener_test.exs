defmodule ShortLy.ShortenerTest do
  use ShortLy.{DataCase}
  alias ShortLy.{Shortener, Shortener.Helper, Shortener.ShortenedLink, Repo}

  @valid_referenced_links %{
    youtube: "https://www.youtube.com",
    facebook: "https://www.facebook.com",
    google: "https://www.google.com"
  }

  setup do
    params = %{referenced_link: @valid_referenced_links[:youtube]}
    {:ok, shortened_link} = Shortener.create_shortened_link(params)
    %{shortened_link: shortened_link}
  end

  describe "get_shortened_link_by_internal_link/1" do
    test "when is passed a valid internal_link, returns a shortened_link struct",
         %{shortened_link: shortened_link_setup} do
      shortened_link =
        shortened_link_setup
        |> Map.get(:internal_link)
        |> Shortener.get_shortened_link_by_internal_link()

      assert shortened_link == shortened_link_setup
    end
  end

  describe "get_shortened_link_by_referenced_link/1" do
    test "when is passed a valid referenced_link, returns a shortened_link struct",
         %{shortened_link: shortened_link_setup} do
      shortened_link =
        shortened_link_setup
        |> Map.get(:referenced_link)
        |> Shortener.get_shortened_link_by_referenced_link()

      assert shortened_link == shortened_link_setup
    end
  end

  describe "create_shortened_link/1" do
    test "when is passed a valid referenced_link, creates a shortened_link" do
      params = %{referenced_link: @valid_referenced_links[:google]}
      count_before_insert = Repo.aggregate(ShortenedLink, :count)

      {:ok, shortened_link} = Shortener.create_shortened_link(params)

      count_after_insert = Repo.aggregate(ShortenedLink, :count)

      assert count_after_insert > count_before_insert
      assert true == shortened_link |> Map.has_key?(:id)
      assert @valid_referenced_links[:google] == shortened_link.referenced_link
    end

    test "when is passed a already used referenced_link, returns the existing shortened_link and increase converted field",
         %{shortened_link: already_exists_shortened_link} do
      params = %{referenced_link: @valid_referenced_links[:youtube]}

      {:already_converted, shortened_link} = Shortener.create_shortened_link(params)

      assert shortened_link.converted > already_exists_shortened_link.converted

      already_exists_shortened_link = already_exists_shortened_link |> Map.put(:converted, 1)

      assert shortened_link == already_exists_shortened_link
    end
  end

  describe "new_shortened_link/1" do
    test "just returns the default changeset, with required fields validation" do
      shortened_link = Shortener.new_shortened_link()
      assert %{referenced_link: ["can't be blank"]} == errors_on(shortened_link)
    end
  end

  describe "list_shortened_links/0" do
    test "should return list of all shortened_links in the database" do
      params = %{referenced_link: @valid_referenced_links[:facebook]}
      Shortener.create_shortened_link(params)

      count_registers = Repo.aggregate(ShortenedLink, :count)
      assert count_registers == Shortener.list_shortened_links() |> length()
    end
  end
end
