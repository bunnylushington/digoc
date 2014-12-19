defmodule DigOcTest do
  use ExUnit.Case

  test "endpoint" do
    assert is_binary(DigOc.endpoint)
    assert String.starts_with? DigOc.endpoint, "https://"
  end
end
