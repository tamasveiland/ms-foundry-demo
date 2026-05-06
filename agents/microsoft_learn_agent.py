# Copyright (c) Microsoft. All rights reserved.
import asyncio
import os

from agent_framework import Agent, MCPStreamableHTTPTool
from agent_framework.foundry import FoundryChatClient
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

# Load environment variables from .env file; override=False so Foundry runtime vars take precedence
load_dotenv(override=False)

"""
This sample creates an agent persisted in AI Foundry using FoundryChatClient.

It connects to the Microsoft Learn MCP server for documentation search,
matching the declarative-agents/MicrosoftLearnAgent.yaml specification.

Environment variables:
- AZURE_AI_PROJECT_ENDPOINT: The endpoint URL for the Foundry project.
- AZURE_AI_PROJECT_MODEL: The model deployment name to use for the agent.
"""


def create_mcp_tools():
    """Create MCP tools matching the MicrosoftLearnAgent.yaml definition."""
    return [
        MCPStreamableHTTPTool(
            name="microsoft_learn",
            description="Get information from Microsoft Learn.",
            url="https://learn.microsoft.com/api/mcp",
            load_prompts=False,
        )
    ]


async def main():
    """Create an agent persisted in AI Foundry and run it."""
    client = FoundryChatClient(
        project_endpoint=os.getenv("AZURE_AI_PROJECT_ENDPOINT"),
        model=os.getenv("AZURE_AI_PROJECT_MODEL"),
        credential=DefaultAzureCredential(),
    )

    async with Agent(
        client=client,
        name="MicrosoftLearnAgent",
        instructions="You answer questions by searching the Microsoft Learn content only.",
        tools=create_mcp_tools(),
    ) as agent:
        print("Agent: ", end="", flush=True)
        stream = agent.run(
            "How do I create a storage account with private endpoint using bicep?",
            stream=True,
        )
        async for chunk in stream:
            if chunk.text:
                print(chunk.text, end="", flush=True)
        print("\n")
        await stream.get_final_response()


if __name__ == "__main__":
    asyncio.run(main())
