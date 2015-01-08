defmodule DigOcDomainsTest do
  use ExUnit.Case

  @ip "162.243.118.118"
  @domain "bapi.us"

  def domain, do: "#{ System.get_pid }-" <> @domain
  
  test "list all domains" do
    assert is_list(DigOc.domains!.domains)
  end

  test "create a domain" do
    assert DigOc.Domain.new!(domain, @ip).domain.name == domain
  end

end