#!/bin/sh

terraform apply


LAKEHOUSE_ID=$(terraform output -raw RawLakehouseID)
WORKSPACE_ID=$(terraform output -raw WorkspaceID)
TOKEN=$(az account get-access-token --scope "https://analysis.windows.net/powerbi/api/.default" | jq -r .accessToken)

curl -i -X POST "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/items/${LAKEHOUSE_ID}/shortcuts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  --data-binary "@req.json"
