defmodule DigOcDomainsTest do
  use ExUnit.Case

  test "list all domains" do
    assert is_list(DigOc.domains!.domains)
  end


end