#!/usr/bin/env bash
set -euo pipefail

ORG="${SONAR_ORGANIZATION:-caiogoulart9}"
PROJECT_KEY="${SONAR_PROJECT_KEY:-Caixa_CI_CD}"
PROJECT_NAME="${SONAR_PROJECT_NAME:-Caixa_CI_CD}"

if [ -z "${SONAR_TOKEN:-}" ]; then
  echo "ERROR: SONAR_TOKEN nao definido."
  echo "Cadastre em: GitHub → Settings → Environments → Caixa_Token → Secret SONAR_TOKEN"
  exit 1
fi

sonar_api() {
  curl -sS -u "${SONAR_TOKEN}:" "$@"
}

echo "==> Validando SONAR_TOKEN no SonarCloud..."
AUTH_RESPONSE="$(sonar_api "https://sonarcloud.io/api/authentication/validate")"
if ! echo "${AUTH_RESPONSE}" | python3 -c "import sys,json; data=json.load(sys.stdin); sys.exit(0 if data.get('valid') else 1)" 2>/dev/null; then
  echo "ERROR: SONAR_TOKEN invalido."
  echo "Resposta: ${AUTH_RESPONSE}"
  echo ""
  echo "O secret SONAR_TOKEN no GitHub deve ser o token de:"
  echo "  https://sonarcloud.io/account/security"
  echo "NAO use Personal Access Token de github.com/settings/tokens"
  exit 1
fi
echo "Token OK."

echo "==> Verificando organizacao '${ORG}'..."
ORG_RESPONSE="$(sonar_api "https://sonarcloud.io/api/organizations/search?organizations=${ORG}")"
ORG_COUNT="$(echo "${ORG_RESPONSE}" | python3 -c "import sys,json; data=json.load(sys.stdin); print(len(data.get('organizations', [])))")"

if [ "${ORG_COUNT}" = "0" ]; then
  echo "ERROR: Organizacao '${ORG}' nao encontrada no SonarCloud."
  echo "Organizacoes disponiveis para este token:"
  ORG_LIST="$(sonar_api "https://sonarcloud.io/api/user/organizations/search?member=true")"
  echo "${ORG_LIST}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
orgs = data.get('organizations', [])
errors = data.get('errors', [])
for e in errors:
    print(f\"  ERRO API: {e.get('msg', e)}\")
if not orgs:
    print('  (nenhuma)')
    print('  Crie a org: https://sonarcloud.io → + → Analyze new project → GitHub')
else:
    for org in orgs:
        print(f\"  - {org.get('key')} ({org.get('name')})\")
    print('')
    print('  Use a key acima em SONAR_ORGANIZATION no firstFase.yml')
"
  exit 1
fi

echo "==> Verificando projeto '${PROJECT_KEY}'..."
SEARCH_RESPONSE="$(sonar_api "https://sonarcloud.io/api/projects/search?projects=${PROJECT_KEY}&organization=${ORG}")"
PROJECT_COUNT="$(echo "${SEARCH_RESPONSE}" | python3 -c "import sys,json; data=json.load(sys.stdin); print(len(data.get('components', [])))")"

if [ "${PROJECT_COUNT}" != "0" ]; then
  echo "Projeto '${PROJECT_KEY}' ja existe."
  exit 0
fi

echo "==> Criando projeto '${PROJECT_KEY}' na organizacao '${ORG}'..."
CREATE_RESPONSE="$(sonar_api -X POST "https://sonarcloud.io/api/projects/create?organization=${ORG}&project=${PROJECT_KEY}&name=${PROJECT_NAME}")"

if echo "${CREATE_RESPONSE}" | python3 -c "import sys,json; data=json.load(sys.stdin); sys.exit(0 if 'project' in data else 1)"; then
  echo "Projeto criado com sucesso."
else
  echo "ERROR: Falha ao criar projeto."
  echo "${CREATE_RESPONSE}"
  exit 1
fi
