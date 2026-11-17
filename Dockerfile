# Builds the stdio MCP server from the source in this repository.
FROM python:3.12-slim
WORKDIR /app
COPY pyproject.toml README.md LICENSE bosco_mcp.py ./
RUN pip install --no-cache-dir .
# Optional: BOSCO_API_KEY (or APIFY_TOKEN) for the 7 paid tools. Without it the server starts,
# lists all 9 tools and the 2 free tools (get_lei_record, find_sec_company) work.
CMD ["bosco-labs-data-mcp"]
