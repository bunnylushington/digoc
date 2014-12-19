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

  test "get actions" do
    {:ok, data, headers} = DigOc.actions(5)
    assert is_map(data)
    assert is_map(headers)
    assert length(data.actions) == 5
  end

  test "pagination" do
    # NB: Works with my acct because I have a ton of actions; YMMV.
    data = DigOc.actions! 5
    assert DigOc.has_next?(data)
    assert DigOc.has_last?(data)
    refute DigOc.has_prev?(data)
    refute DigOc.has_first?(data)

    new_data = DigOc.next_page!(data)
    assert DigOc.has_prev?(new_data)
    assert DigOc.has_first?(new_data)
  end

  test "single action" do
    actions = DigOc.actions! 1
    action = hd(actions.actions)
    other_action = DigOc.action! action.id
    assert action == other_action.action
  end
    
    
                       

end
