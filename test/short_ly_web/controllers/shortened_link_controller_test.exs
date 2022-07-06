defmodule ShortLyWeb.ShortenedLinkControllerTest do
  use ShortLyWeb.ConnCase, async: false
  alias ShortLy.{Shortener, Shortener.Helper, Shortener.ShortenedLink, Repo}
  import Ecto.Query

  @google_link "https://www.google.com"
  @youtube_link "https://www.youtube.com"
  @invalid_link "www.isnotaccepted.com.without.full.format"
  @invalid_internal_link "onepieceisjustthatgood"
  setup %{conn: conn} do
    {:ok, %ShortenedLink{internal_link: internal_link}} =
      Shortener.create_shortened_link(%{referenced_link: @google_link})

    {:ok, conn: conn, internal_link: internal_link}
  end

  describe "new/2" do
    test "returns a page with a form to create a shortened_link", %{conn: conn} do
      response = conn |> get(Routes.shortened_link_path(conn, :new)) |> html_response(:ok)
      assert response =~ "Shortify"
      assert response =~ "form"
    end
  end

  describe "create/2" do
    test "when passed a valid referenced_link, creates a shortened_link and redirect to index page",
         %{conn: conn} do
      params = %{"shortened_link" => %{referenced_link: @youtube_link}}

      conn = conn |> post(Routes.shortened_link_path(conn, :create, params))

      # assert redirect to index page
      assert "/" = redirect_path = redirected_to(conn, 302)

      # get html_response from index page
      response = conn |> recycle() |> get(redirect_path) |> html_response(200)

      # verify if created on database
      assert %ShortenedLink{referenced_link: @youtube_link} =
               Shortener.get_shortened_link_by_referenced_link(@youtube_link)

      assert response =~ "Url generated successfully."
    end

    test "when passed a valid referenced_link but already exists, returns it shortened_link and redirect to index page",
         %{conn: conn} do
      params = %{"shortened_link" => %{referenced_link: @google_link}}

      count_before_attempt_to_insert = Repo.aggregate(ShortenedLink, :count)
      conn = conn |> post(Routes.shortened_link_path(conn, :create, params))
      count_after_attempt_to_insert = Repo.aggregate(ShortenedLink, :count)

      assert count_before_attempt_to_insert == count_after_attempt_to_insert

      assert "/" = redirect_path = redirected_to(conn, 302)

      redirect_response = conn |> recycle() |> get(redirect_path) |> html_response(200)

      assert redirect_response =~ "Already exists."
    end

    test "when receive invalid params, returns a changeset with error", %{conn: conn} do
      params = %{"shortened_link" => %{referenced_link: @invalid_link}}

      response =
        conn |> post(Routes.shortened_link_path(conn, :create, params)) |> html_response(:ok)

      assert response =~ "The link is invalid, please put the full URL"
    end
  end

  describe "show/2" do
    test "when passed a valid internal_link, redirect to the referenced_link",
         %{conn: conn, internal_link: internal_link} do
      conn = conn |> get(Routes.shortened_link_path(conn, :show, internal_link))

      assert @google_link = redirect_path = redirected_to(conn, 302)
    end

    test "when passed a invalid internal_link, redirect to the index page with errors",
         %{conn: conn} do
      conn = conn |> get(Routes.shortened_link_path(conn, :show, @invalid_internal_link))

      assert "/" = redirect_path = redirected_to(conn, 302)

      redirect_response = conn |> recycle() |> get(redirect_path) |> html_response(200)

      assert redirect_response =~ "Link not founded, try again:"
    end
  end
end
