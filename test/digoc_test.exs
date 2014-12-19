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

  test "account" do
    {:ok, data, headers} = DigOc.account
    assert is_map(data)
    assert is_map(headers)
    assert is_integer(data.account.droplet_limit)
    assert is_binary(data.account.email)
    assert is_boolean(data.account.email_verified)
    assert DigOc.account! == data
  end

end
