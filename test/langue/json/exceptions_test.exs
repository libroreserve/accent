defmodule LangueTest.Formatter.Json.Exception do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Langue.Formatter.Json
  alias LangueTest.Formatter.Json.Expectation.InvalidFloatValue
  alias LangueTest.Formatter.Json.Expectation.InvalidIntegerValue

  Code.require_file("expectation_test.exs", __DIR__)

  test "invalid integer value" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_serialize(InvalidIntegerValue, Json)

    assert expected_parse == result_parse
  end

  test "invalid float value" do
    {expected_parse, result_parse} = Accent.FormatterTestHelper.test_serialize(InvalidFloatValue, Json)

    assert expected_parse == result_parse
  end
end
