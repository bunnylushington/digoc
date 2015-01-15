# DigOc #

An Elixir client for the Digital Ocean API.  If you find errors, please don't hesitate to file a GitHub issue.

DigOc API Documentation is available at http://hexdocs.pm/digoc

The [Digital Ocean API documenation](https://developers.digitalocean.com/) will prove helpful.

[Please note: the "examples" documentation effort here is ongoing but I believe the API is fully documented.  If something there is confusing or missing or just plain wrong it's a bug; please file a GitHub issue.]

## Porcelain vs. Plumbing ##

I'm working on a [separate
library](https://github.com/kevinmontuori/DigitalOcean) that wraps this library with more developer friendly functions.  That is a work in progress and in no way deprecates this code (quite the opposite: it relies on it).  If you're doing anything more than a quick 'n' dirty script, it might be worth taking a look.  

## Authentication ##

Generate a Digital Ocean from the [Applications & API
page](https://cloud.digitalocean.com/settings/applications).  Set the environment variable `DIGOC_API2_TOKEN` to the value of the token.

This value is available programmatically:

    iex> DigOc.api_token
    "12345...7890"

## Results ##

All of the commands have two varients, e.g., `DigOc.account/0` and `DigOc.account!/0`.  The first returns a three-tuple:

    iex> DigOc.account
    {:ok,
     %{account: %{droplet_limit: 25, email: "quux@example.com",
         email_verified: true, uuid: "12345"}},
     %{"CF-RAY" => "1a6a3abe45cf115f-DFW",
       "Content-Type" => "application/json; charset=utf-8",
       "RateLimit-Limit" => "1200",
       "RateLimit-Remaining" => "1199",
       "RateLimit-Reset" => "1420910715",
       "Server" => "cloudflare-nginx",
       "Status" => "200 OK"}}`
    

The latter just the response body:

    iex> DigOc.account!
    %{account: %{droplet_limit: 25, email: "quux@example.com",
    email_verified: true, uuid: "12345"}}

The response body is the original JSON decoded by Poison.  I've given some thought to making these actual records but don't see that there's a real benefit to that (in fact, that just opens the door to more maintenance when the API changes).  If you think otherwise, please let me know.

## Examples ##

NB: The results shown have been edited and often truncated.  For documentation on the datastructures that are being returned, please consult the [D.O. API v2 documentation](https://developers.digitalocean.com/).  


### Account ###

    iex(8)> DigOc.account!
    %{account: %{droplet_limit: 25, email: "quuxor@example.com",
        email_verified: true, uuid: "12345"}}

### Actions and Pagination ###

    iex(10)> res = DigOc.actions!(3)
    %{actions: [%{completed_at: "2015-01-10T16:07:39Z", id: 40940233,
         region: "nyc3", resource_id: 3723327, resource_type: "droplet",
         started_at: "2015-01-10T16:07:36Z", status: "completed",
         type: "destroy"},
       %{completed_at: "2015-01-09T20:31:21Z", id: 40885160, region: "nyc3",
         resource_id: 3723351, resource_type: "droplet",
         started_at: "2015-01-09T20:31:16Z", status: "completed",
         type: "destroy"},
       %{completed_at: "2015-01-09T20:31:15Z", id: 40885158, region: "nyc3",
         resource_id: 3723351, resource_type: "droplet",
         started_at: "2015-01-09T20:31:15Z", status: "completed",
         type: "rename"}],
     links: %{pages:
         %{last: "https://api.digitalocean.com/v2/actions?page=382&per_page=3",
           next: "https://api.digitalocean.com/v2/actions?page=2&per_page=3"}},
     meta: %{total: 1144}}
           
    iex(12)> DigOc.Page.next?(res)
    true
    iex(13)> DigOc.Page.last?(res)
    true
    iex(14)> DigOc.Page.prev?(res)
    false

    iex(16)> last_res = DigOc.Page.last!(res)
    %{actions: [%{completed_at: "2012-09-20T17:59:05Z", id: 137720,
                  region: "nyc1", resource_id: 25817, resource_type: "droplet",
                  started_at: "2012-09-20T17:58:05Z", status: "completed",
                  type: "create"}],
      links: %{pages:
       %{first: "https://api.digitalocean.com/v2/actions?page=1&per_page=3",
         prev: "https://api.digitalocean.com/v2/actions?page=381&per_page=3"}},
      meta: %{total: 1144}}

    iex(18)> DigOc.Page.next!(last_res)
    ** (RuntimeError) No bookmark for next page.
        (digoc) lib/digoc/page.ex:24: DigOc.Page.get_page/2
        (digoc) lib/digoc/page.ex:13: DigOc.Page.next!/1


    iex(18)> DigOc.action!(40940233)
    %{action: %{completed_at: "2015-01-10T16:07:39Z", id: 40940233,
        region: "nyc3", resource_id: 3723327, resource_type: "droplet",
        started_at: "2015-01-10T16:07:36Z", status: "completed",
        type: "destroy"}}


### Domains ###

    iex(26)>  DigOc.Domain.new!("bapi.us", "10.0.0.1")
    %{domain: %{name: "bapi.us", ttl: 1800, zone_file: nil}}

    iex(29)>  DigOc.Domain.new!("another.bapi.us", "10.0.0.1")
    %{domain: %{name: "another.bapi.us", ttl: 1800, zone_file: nil}}

    iex(30)> DigOc.domains!
    %{domains: [%{name: "bapi.us", ttl: 1800,
         zone_file: "$ORIGIN bapi.us.\n..."},
       %{name: "another.bapi.us", ttl: 1800,
         zone_file: "$ORIGIN another.bapi.us.\n..."}],
      links: %{}, meta: %{total: 2}}

    iex(32)> DigOc.domain!("another.bapi.us")
    %{domain: %{name: "another.bapi.us", ttl: 1800,
        zone_file: "$ORIGIN another.bapi.us.\n..."}}

    ex(2)> DigOc.Domain.delete("another.bapi.us")
    {:ok, "", %{"Status" => "204 No Content"}}


### Domain Records ###

    iex(3)>  DigOc.Domain.Record.new!("bapi.us", %{ type: "A",
                                                    name: "test.bapi.us",
                                                    data: "10.0.0.2" })
    %{domain_record: %{data: "10.0.0.2", id: 3833327, name: "test.bapi.us",
    port: nil, priority: nil, type: "A", weight: nil}}

    iex(4)> DigOc.Domain.records!("bapi.us")
    %{domain_records: [%{data: "ns1.digitalocean.com", id: 3833164, name: "@",
         port: nil, priority: nil, type: "NS", weight: nil},
       %{data: "ns2.digitalocean.com", id: 3833165, name: "@", port: nil,
         priority: nil, type: "NS", weight: nil},
       %{data: "ns3.digitalocean.com", id: 3833166, name: "@", port: nil,
         priority: nil, type: "NS", weight: nil},
       %{data: "10.0.0.1", id: 3833167, name: "@", port: nil, priority: nil,
         type: "A", weight: nil},
       %{data: "10.0.0.2", id: 3833326, name: "test.bapi.us", port: nil,
         priority: nil, type: "A", weight: nil},
       %{data: "10.0.0.2", id: 3833327, name: "test.bapi.us", port: nil,
         priority: nil, type: "A", weight: nil}], links: %{}, meta: %{total: 6}}

    iex(9)> DigOc.Domain.record!("bapi.us", 3833327)
    %{domain_record: %{data: "10.0.0.2", id: 3833327, name: "test.bapi.us",
    port: nil, priority: nil, type: "A", weight: nil}}

    iex(2)> DigOc.Domain.Record.update!("bapi.us", 3833327, "prod.bapi.us")
    %{domain_record: %{data: "10.0.0.2", id: 3833327, name: "prod.bapi.us",
        port: nil, priority: nil, type: "A", weight: nil}}

    iex(3)> DigOc.Domain.Record.delete("bapi.us", 3833327)
    {:ok, "", %{"Status" => "204 No Content"}}

## Copyright ##

This library is (c) 2015 BAPI Consulting and released under the MIT License.







