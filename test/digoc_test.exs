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

  # test "pagination" do
  #   # NB: Works with my acct because I have a ton of actions; YMMV.
  #   data = DigOc.actions! 5
  #   assert DigOc.has_next?(data)
  #   assert DigOc.has_last?(data)
  #   refute DigOc.has_prev?(data)
  #   refute DigOc.has_first?(data)

  #   new_data = DigOc.next_page!(data)
  #   assert DigOc.has_prev?(new_data)
  #   assert DigOc.has_first?(new_data)
  # end

  test "single action" do
    actions = DigOc.actions! 1
    action = hd(actions.actions)
    other_action = DigOc.action! action.id
    assert action == other_action.action
  end

  test "get keys" do
    keys = DigOc.keys!()
    assert length(keys.ssh_keys) == keys.meta.total
    {:ok, data, _headers} = DigOc.keys
    assert keys.ssh_keys == data.ssh_keys
  end

  test "get a key" do
    keys = DigOc.keys!()
    key = hd(keys.ssh_keys)
    key_by_id = DigOc.key!(key.id).ssh_key
    key_by_fingerprint = DigOc.key!(key.fingerprint).ssh_key
    assert key == key_by_id
    assert key == key_by_fingerprint
  end

  test "crud key" do
    pubkey = File.read!("test/testkey.pub")
    {:ok, res, _headers} = DigOc.key(:new, "testkey", pubkey)
    res2 = DigOc.key!(:new, "testkey", pubkey)
    assert res.ssh_key.name == "testkey"
    assert res2.id == "unprocessable_entity"
    rename = DigOc.key!(:update, res.ssh_key.id, "newtestkey")
    assert rename.ssh_key.name == "newtestkey"
    assert rename.ssh_key.fingerprint == res.ssh_key.fingerprint
    {:ok, "", headers} = DigOc.key(:destroy, res.ssh_key.id)
    assert headers["Status"] == "204 No Content"
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
