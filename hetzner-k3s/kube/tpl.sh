
FILE="$1"
if [ ! -f "$FILE" ]; then
  echo "No file found: $FILE"
  exit 1
fi;

DOC=$(yq 'select(.kind == "HelmChart")' "$FILE")

NAME=$(echo "$DOC" | yq '.metadata.name')
NAMESPACE=$(echo "$DOC" | yq '.metadata.namespace')

REPO=$(echo "$DOC" | yq '.spec.repo')
CHART=$(echo "$DOC" | yq '.spec.chart')

VERSION=$(echo "$DOC" | yq '.spec.version')
VALUES=$(echo "$DOC" | yq '.spec.valuesContent')

# TODO: add repo if not exists.
# TODO: update repo if version not found.
REPO_NAME=$(helm repo list | grep "$REPO" | cut -d' ' -f1)

echo "$VALUES" | helm template "$NAME" "$REPO_NAME/$CHART" \
  --namespace "$NAMESPACE" --version "$VERSION" -f -
