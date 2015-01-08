defmodule DigOcDomainsTest do
  use ExUnit.Case

  @ip "162.243.118.118"
  @domain "bapi.us"

  def domain, do: "#{ System.get_pid }-" <> @domain
  
  test "list all domains" do
    assert is_list(DigOc.domains!.domains)
  end

  test "create, retrieve, and delete a domain" do
    d = DigOc.Domain.new!(domain, @ip)
    assert d.domain.name == domain
    retrieved = DigOc.domain!(domain)
    assert retrieved.domain.name == d.domain.name
    {_, "", headers} = DigOc.Domain.delete(domain)
    assert headers["Status"] == "204 No Content"
    
  end




end