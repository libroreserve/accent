defmodule Langue.Formatter.Gettext.Parser do
  @behaviour Langue.Formatter.Parser

  @plural_value_type "plural"

  alias Langue.Entry

  def parse(%{render: render}) do
    {:ok, po} = Gettext.PO.parse_string(render)
    entries = parse_translations(po)
    top_of_the_file_comment = join_string(po.top_of_the_file_comments)
    header = join_string(po.headers)

    %Langue.Formatter.ParserResult{
      entries: entries,
      top_of_the_file_comment: top_of_the_file_comment,
      header: header
    }
  end

  defp parse_translations(%{translations: translations}) do
    translations
    |> Enum.with_index(1)
    |> Enum.flat_map(&parse_translation/1)
  end

  defp parse_translation({translation = %{msgid_plural: _}, index}) do
    plural_entry = %Entry{
      index: index,
      comment: join_string(translation.comments),
      key: join_string(translation.msgid) <> key_suffix("_"),
      value: join_string(translation.msgid_plural),
      value_type: @plural_value_type
    }

    translation.msgstr
    |> Enum.reduce([plural_entry], fn {plural_index, value}, acc ->
      Enum.concat(acc, [
        %Entry{
          index: index,
          key: join_string(translation.msgid) <> key_suffix(plural_index),
          value: join_string(value),
          value_type: @plural_value_type
        }
      ])
    end)
  end

  defp parse_translation({translation, index}) do
    [
      %Entry{
        index: index,
        comment: join_string(translation.comments),
        key: join_string(translation.msgid),
        value: join_string(translation.msgstr)
      }
    ]
  end

  defp join_string([]), do: nil
  defp join_string(list), do: Enum.join(list, "\n")

  defp key_suffix(id), do: ".__KEY__#{id}"
end
