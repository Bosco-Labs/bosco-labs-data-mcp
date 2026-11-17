<!-- mcp-name: io.github.Bosco-Labs/bosco-labs-data -->

# Bosco Labs data: MCP server

This repository is the source of a stdio MCP server, written in Python on the official
[MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk). The whole implementation
is [`bosco_mcp.py`](bosco_mcp.py): 9 read-only tools that give AI agents official-source data,
with a source link on every row. It runs on your machine.

- **2 free tools** call the open official APIs directly (GLEIF and SEC EDGAR): no token, no key.
- **7 paid tools** call the [Bosco Labs HTTP API](https://boscolabs.dev/api.html) with your
  Bosco Labs key (`BOSCO_API_KEY`) and return a compact, typed result. You pay per row returned,
  from prepaid credits. A new key comes with **$5.00 of free credit, no card**:
  https://boscolabs.dev/api.html#key
- Already have an Apify account? Set `APIFY_TOKEN` instead: the same tools then run as public
  [Bosco Labs Apify Actors](https://apify.com/Bosco_labs), billed to your Apify account.

Published on PyPI as [`bosco-labs-data-mcp`](https://pypi.org/project/bosco-labs-data-mcp/) and
in the official MCP Registry as `io.github.Bosco-Labs/bosco-labs-data`. MIT licensed.

## Tools

| Tool | Data (source) | Cost |
|---|---|---|
| `get_lei_record` | LEI, legal name, status, jurisdiction, registration number and ultimate parent of any legal entity (GLEIF, CC0) | free |
| `find_sec_company` | CIK, official name, tickers, exchanges, SIC industry, state of incorporation (SEC EDGAR) | free |
| `get_eu_annual_reports` | Audited financials of EU/UK listed companies (ESEF reports, filings.xbrl.org) | $0.05 per row (on Apify + $0.01 per call) |
| `get_company_accounts` | Accounts of UK, Danish and Norwegian companies, incl. private ones (Companies House, Erhvervsstyrelsen, Brønnøysund) | $0.04 per row |
| `search_sec_insider_trades` | Form 4 insider purchases and sales since 2006, cluster buys and sells (SEC EDGAR) | $0.0018 per row |
| `search_sec_filings` | Any EDGAR filing since 1994: 8-K items, 10-K, 10-Q, earnings release times (SEC EDGAR) | $0.001 per row |
| `search_us_house_stock_trades` | STOCK Act trades of House members since 2014 (Clerk of the House) | $0.0018 per row |
| `search_eu_tenders` | EU/EEA public tenders and contract awards (TED) | $0.002 per row |
| `search_dod_contract_awards` | DoD (or any federal agency) contract awards since FY2008, with winner tickers (USAspending.gov) | $0.005 per row |

Every tool has a `max_results` parameter with a small default and a hard maximum, so one call
costs cents. Results of the free tools include `next_steps`: the paid call that gives the full
picture. Without a key the paid tools answer where to get one; the free tools still work.

## Changes in 0.4.0

All tools were renamed to one verb_noun scheme, the scheme the Bosco Labs remote MCP server
(https://api.boscolabs.dev/mcp) uses too. Inputs and outputs did not change. Scripts or configs that call a tool by its old name
must use the new one; the old names no longer exist.

| Before 0.4.0 | From 0.4.0 |
|---|---|
| `lei_lookup` | `get_lei_record` |
| `sec_company_lookup` | `find_sec_company` |
| `eu_annual_report_financials` | `get_eu_annual_reports` |
| `european_company_accounts` | `get_company_accounts` |
| `sec_insider_trades` | `search_sec_insider_trades` |
| `sec_filings` | `search_sec_filings` |
| `us_house_stock_trades` | `search_us_house_stock_trades` |
| `eu_public_tenders` | `search_eu_tenders` |
| `dod_contract_awards` | `search_dod_contract_awards` |

## How it works

- `get_lei_record` and `find_sec_company` query `api.gleif.org` and `sec.gov` / `data.sec.gov`
  with a declared User-Agent, one retry on 429/5xx, and the SEC fair-access limit in mind.
- With `BOSCO_API_KEY`, the paid tools `POST api.boscolabs.dev/v1/<tool>` with the input built
  from the tool's typed parameters, then keep only the fields an agent needs. With only
  `APIFY_TOKEN`, they call `api.apify.com/v2/acts/<actor>/run-sync-get-dataset-items` with the
  same input. If both are set, `BOSCO_API_KEY` is used.
- No state, no database, no telemetry. The only network hosts are `api.gleif.org`,
  `www.sec.gov`, `data.sec.gov`, `api.boscolabs.dev` and `api.apify.com`.

## Run it

With [uv](https://docs.astral.sh/uv/), from PyPI:

```bash
claude mcp add bosco-labs-data -e BOSCO_API_KEY=bl_live_... -- uvx bosco-labs-data-mcp
```

From this source:

```bash
git clone https://github.com/Bosco-Labs/bosco-labs-data-mcp
cd bosco-labs-data-mcp
uv run bosco-labs-data-mcp          # stdio; set BOSCO_API_KEY for the paid tools
```

Or with Docker: `docker build -t bosco-labs-data-mcp . && docker run -i --rm -e BOSCO_API_KEY bosco-labs-data-mcp`.

Claude Desktop or Cursor (`claude_desktop_config.json`, `~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "bosco-labs-data": {
      "command": "uvx",
      "args": ["bosco-labs-data-mcp"],
      "env": { "BOSCO_API_KEY": "bl_live_..." }
    }
  }
}
```

Get a key ($5.00 free credit, no card) at https://boscolabs.dev/api.html#key; it is not needed
for the free tools. Apify users can put `"APIFY_TOKEN": "apify_api_..."` there instead
(https://console.apify.com/settings/integrations).

## Tests

```bash
uv run --with pytest pytest -q    # the APIs are mocked, plus a stdio smoke test
```

## Related

The same key also works on the Bosco Labs remote MCP server (`https://api.boscolabs.dev/mcp`),
which has more tools (company registers, counterparty checks, sanctions screening, EU law and
more): https://boscolabs.dev. That server is not part of this repository.
