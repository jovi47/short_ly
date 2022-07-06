defmodule ShortLy.Shortener.Helper do
  @accepted_chars '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTVUWXYZ'
  def generate_internal_link() do
    for(_ <- 1..7, into: "", do: <<Enum.random(@accepted_chars)>>)
  end

  def validate_link(link) do
    link
    |> URI.parse()
    |> check_required_fields_in_uri()
  end

  defp check_required_fields_in_uri(%URI{} = uri),
    do: !is_nil(uri.host) and !is_nil(uri.scheme) and !is_nil(uri.port)
end
