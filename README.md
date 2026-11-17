<!-- mcp-name: io.github.Bosco-Labs/bosco-labs-data -->

# Bosco Labs data: MCP server

This repository is the source of a stdio MCP server, written in Python on the official
[MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk). The whole implementation
is [`bosco_mcp.py`](bosco_mcp.py): 9 read-only tools that give AI agents official-source data,
with a source link on every row. It runs on your machine; nothing is proxied through a Bosco
Labs server.

- **2 free tools** call the open official APIs directly (GLEIF and SEC EDGAR): no token, no key.
- **7 paid tools** each start one public [Bosco Labs Apify Actor](https://apify.com/Bosco_labs)
  through the Apify REST API with **your own** Apify token, wait for it, and return a compact,
  typed result. You pay Apify per row returned.

Published on PyPI as [`bosco-labs-data-mcp`](https://pypi.org/project/bosco-labs-data-mcp/) and
in the official MCP Registry as `io.github.Bosco-Labs/bosco-labs-data`. MIT licensed.

## Tools

| Tool | Data (source) | Cost |
|---|---|---|
| `lei_lookup` | LEI, legal name, status, jurisdiction, registration number and ultimate parent of any legal entity (GLEIF, CC0) | free |
| `sec_company_lookup` | CIK, official name, tickers, exchanges, SIC industry, state of incorporation (SEC EDGAR) | free |
| `eu_annual_report_financials` | Audited financials of EU/UK listed companies (ESEF reports, filings.xbrl.org) | $0.05 per row + $0.01 per call |
| `european_company_accounts` | Accounts of UK, Danish and Norwegian companies, incl. private ones (Companies House, Erhvervsstyrelsen, Brønnøysund) | $0.04 per row |
| `sec_insider_trades` | Form 4 insider purchases and sales since 2006, cluster buys and sells (SEC EDGAR) | $0.0018 per row |
| `sec_filings` | Any EDGAR filing since 1994: 8-K items, 10-K, 10-Q, earnings release times (SEC EDGAR) | $0.001 per row |
| `us_house_stock_trades` | STOCK Act trades of House members since 2014 (Clerk of the House) | $0.0018 per row |
| `eu_public_tenders` | EU/EEA public tenders and contract awards (TED) | $0.002 per row |
| `dod_contract_awards` | DoD (or any federal agency) contract awards since FY2008, with winner tickers (USAspending.gov) | $0.005 per row |

Every tool has a `max_results` parameter with a small default and a hard maximum, so one call
costs cents. Results of the free tools include `next_steps`: the paid call that gives the full
picture. Without a token the paid tools answer that a token is needed; the free tools still work.

## How it works

- `lei_lookup` and `sec_company_lookup` query `api.gleif.org` and `sec.gov` / `data.sec.gov`
  with a declared User-Agent, one retry on 429/5xx, and the SEC fair-access limit in mind.
- The paid tools call `api.apify.com/v2/acts/<actor>/run-sync-get-dataset-items` with the
  input built from the tool's typed parameters, then keep only the fields an agent needs.
- No state, no database, no telemetry. The only network hosts are `api.gleif.org`,
  `www.sec.gov`, `data.sec.gov` and `api.apify.com`.

## Run it

With [uv](https://docs.astral.sh/uv/), from PyPI:

```bash
claude mcp add bosco-labs-data -e APIFY_TOKEN=apify_api_... -- uvx bosco-labs-data-mcp
```

From this source:

```bash
git clone https://github.com/Bosco-Labs/bosco-labs-data-mcp
cd bosco-labs-data-mcp
uv run bosco-labs-data-mcp          # stdio; set APIFY_TOKEN for the paid tools
```

Or with Docker: `docker build -t bosco-labs-data-mcp . && docker run -i --rm -e APIFY_TOKEN bosco-labs-data-mcp`.

Claude Desktop or Cursor (`claude_desktop_config.json`, `~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "bosco-labs-data": {
      "command": "uvx",
      "args": ["bosco-labs-data-mcp"],
      "env": { "APIFY_TOKEN": "apify_api_..." }
    }
  }
}
```

Get an Apify token at https://console.apify.com/settings/integrations (not needed for the free
tools).

## Tests

```bash
uv run --with pytest pytest -q    # Apify, GLEIF and SEC are mocked, plus a stdio smoke test
```

## Related

Bosco Labs also runs a hosted API and remote MCP server with more tools (company registers,
counterparty checks, sanctions screening, EU law and more) at https://boscolabs.dev. It is a
separate service and not part of this repository.
