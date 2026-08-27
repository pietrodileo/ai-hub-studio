import asyncio
import base64
import os

from langchain_mcp_adapters.client import MultiServerMCPClient


async def main():
    user = os.environ["APP_USER"]
    password = os.environ["APP_PASS"]
    token = base64.b64encode(f"{user}:{password}".encode()).decode()
    client = MultiServerMCPClient(
        {
            "iris_data": {
                "transport": "http",
                "url": "http://localhost:8080/mcp/data",
                "headers": {"Authorization": f"Basic {token}"},
            }
        }
    )
    tools = await client.get_tools()
    if not tools:
        raise RuntimeError("No MCP tools discovered")
    print("Discovered:", ", ".join(sorted(tool.name for tool in tools)))


if __name__ == "__main__":
    asyncio.run(main())
