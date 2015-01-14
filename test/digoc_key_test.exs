defmodule DigOcTestKeys do
  use ExUnit.Case

  @moduletag :external
  
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
    {:ok, res, _headers} = DigOc.Key.new("testkey", pubkey)
    res2 = DigOc.Key.new!("testkey", pubkey)
    assert res.ssh_key.name == "testkey"
    assert res2.id == "unprocessable_entity"
    rename = DigOc.Key.update!(res.ssh_key.id, "newtestkey")
    assert rename.ssh_key.name == "newtestkey"
    assert rename.ssh_key.fingerprint == res.ssh_key.fingerprint
    {:ok, "", headers} = DigOc.Key.destroy(res.ssh_key.id)
    assert headers["Status"] == "204 No Content"
  end


end
