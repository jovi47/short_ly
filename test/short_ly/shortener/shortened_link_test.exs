defmodule ShortLy.Shortener.ShortenedLinkTest do
  use ShortLy.{DataCase}

  alias ShortLy.{Shortener.ShortenedLink}

  @valid_link "https://www.youtube.com"
  @invalid_link "www.youtube.com"

  describe "changeset/2" do
    test "when passed valid params(without link validation), returns a valid changeset" do
      params = %{referenced_link: @valid_link}

      response = ShortenedLink.changeset(params)

      assert true == response.valid?
    end

    test "when there are invalid params(without link validation), returns as invalid changeset" do
      params = %{batata: "batata"}

      response = ShortenedLink.changeset(params)

      assert %{referenced_link: ["can't be blank"]} == errors_on(response)
    end
  end

  describe "validate_referenced_link/1" do
    test "when receive a changeset with a valid link, just returns the changeset" do
      params = %{referenced_link: @valid_link}

      response =
        ShortenedLink.changeset(params)
        |> ShortenedLink.validate_referenced_link()

      assert true == response.valid?
    end

    test "when receive a changeset with a invalid link, puts an error on the changeset and returns" do
      params = %{referenced_link: @invalid_link}

      response =
        ShortenedLink.changeset(params)
        |> ShortenedLink.validate_referenced_link()

      assert %{referenced_link: ["The link is invalid, please put the full URL"]} ==
               errors_on(response)
    end
  end

  describe "put_internal_link/1" do
    test "generates a internal_link and put into the changeset" do
      params = %{referenced_link: @valid_link}

      response =
        ShortenedLink.changeset(params)
        |> ShortenedLink.put_internal_link()

      assert true == response |> Map.get(:changes) |> Map.has_key?(:internal_link)
    end
  end
end
