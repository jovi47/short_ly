defmodule ShortLyWeb.ShortenedLinkView do
  use ShortLyWeb, :view
  # import Ecto.Changeset, only: [traverse_errors: 2]

  # defp translate_errors(changeset) do
  #   traverse_errors(changeset, fn {msg, opts} ->
  #     Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
  #       opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
  #     end)
  #   end)
  # end

  # def mapper(%Ecto.Changeset{} = changeset) do
  #   Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
  #     Enum.reduce(opts, msg, fn {key, value}, acc ->
  #       String.replace(acc, "%{#{key}}", _to_string(value))
  #     end)
  #   end)
  #   |> Enum.reduce("", fn {k, v}, acc ->
  #     joined_errors = Enum.join(v, "; ")
  #     "#{acc}#{joined_errors}"
  #   end)
  #   |> String.replace("\"", "")
  # end

  # def mapper(changeset), do: changeset

  # defp _to_string(val) when is_list(val) do
  #   Enum.join(val, ",")
  # end

  # defp _to_string(val), do: to_string(val)
end
