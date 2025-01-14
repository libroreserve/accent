defmodule Accent.Lint.Checks.Spelling do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @impl true
  def enabled?, do: LanguageTool.available?()

  @impl true
  def applicable(entry) do
    LanguageTool.ready?() and
      is_binary(entry.value) and
      not String.match?(entry.value, ~r/MMM|YYY|HH|AA/i) and
      not String.starts_with?(entry.value, "{") and
      ((!entry.is_master and entry.value !== entry.master_value) or entry.is_master) and
      String.length(entry.value) < 100 and String.length(entry.value) > 3
  end

  @impl true
  def check(entry) do
    {matches, markups} =
      case LanguageTool.check(entry.language_slug, entry.value, placeholder_regex: entry.placeholder_regex) do
        %{"matches" => matches, "markups" => markups} -> {matches, markups}
        _ -> {[], []}
      end

    for match <- matches do
      offset = match["offset"] + length(markups)

      replacement =
        case match["replacements"] do
          [%{"value" => fixed_value} | _] ->
            value =
              String.replace(
                entry.value,
                String.slice(entry.value, offset, match["length"]),
                fixed_value
              )

            %Replacement{value: value, label: fixed_value}

          _ ->
            nil
        end

      %Message{
        check: :spelling,
        text: entry.value,
        offset: offset,
        length: match["length"],
        message: match["message"],
        replacement: replacement
      }
    end
  end
end
