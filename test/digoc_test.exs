defmodule DigOcTest do
  use ExUnit.Case

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

  test "get actions" do
    {:ok, data, headers} = DigOc.actions(5)
    assert is_map(data)
    assert is_map(headers)
    assert length(data.actions) == 5
  end

  test "single action" do
    actions = DigOc.actions! 1
    action = hd(actions.actions)
    other_action = DigOc.action! action.id
    assert action == other_action.action
  end

  test "regions" do
    regions = DigOc.regions!()
    assert length(regions.regions) == regions.meta.total
    {:ok, data, _headers} = DigOc.regions
    assert data.regions == regions.regions
  end

  test "sizes" do
    sizes = DigOc.sizes!()
    assert length(sizes.sizes) == sizes.meta.total
    {:ok, data, _headers} = DigOc.sizes
    assert data.sizes == sizes.sizes
  end
                    
end
