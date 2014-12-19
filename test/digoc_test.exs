defmodule DigOcTest do
  use ExUnit.Case

  test "endpoint" do
    assert is_binary(DigOc.endpoint)
    assert String.starts_with? DigOc.endpoint, "https://"
  end

  test "token" do
    assert is_binary(DigOc.api_token)
    assert String.length(DigOc.api_token) == 64
  end

end
