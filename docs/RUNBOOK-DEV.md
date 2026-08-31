# Runbook de Operacao do Repositorio Apps (Dev)

## Objetivo
Executar o ciclo completo de CI e entrega de imagens para os microsservicos do ToggleMaster no ambiente `dev`.

## Escopo
- Build, teste e lint por microsservico.
- Scans de seguranca (SCA e SAST).
- Build/push de imagem no ECR.
- Atualizacao automatica do values correspondente no repositório GitOps.

## Pré-requisitos
- Templates `validate.yml`, `security.yml`, `image.yml` e `update-gitops.yml` publicados no repositório `togglemaster-cicd-templates` e acessíveis pelo GitHub Actions.
- Secrets configurados no repositório `togglemaster-apps`:
  - `SONAR_TOKEN` (opcional)
- Variáveis `AWS_ROLE_TO_ASSUME` e `AWS_REGION` no GitHub Environment `dev`.
- Roles OIDC de build com permissao de push no ECR.
- Secrets `GITOPS_TOKEN` e `GITOPS_REPO` para criar Pull Requests no repositorio GitOps.

## Configuração manual no GitHub

Em `Settings > Environments > dev > Environment variables` do repositorio `togglemaster-apps`:

1. Cadastre a variable `AWS_ROLE_TO_ASSUME` com o ARN da role
  `togglemaster-dev-github-actions-ecr-role`.
2. Cadastre `SONAR_TOKEN` somente se a analise SonarCloud estiver habilitada.
3. Em `Settings > Actions > General`, permita as actions e reusable workflows do
  repositorio `togglemaster-cicd-templates`.
4. Em `Settings > Branches`, proteja a branch do laboratorio e exija os checks de validacao.

O job de publicação usa `environment: dev`; a role ECR deve confiar no subject
`repo:<owner>/togglemaster-apps:environment:dev`.

## Workflows por microsservico
- `auth-service-ci.yml`
- `flag-service-ci.yml`
- `targeting-service-ci.yml`
- `evaluation-service-ci.yml`
- `analytics-service-ci.yml`

## Procedimento de execução

### 1. Pull Request
1. Criar uma branch e alterar apenas um microsservico.
2. Abrir PR para `main`.
3. Confirmar execucao do workflow correspondente ao microsservico alterado.
4. Validar jobs de build, lint, SCA e SAST.
6. Se houver vulnerabilidade `CRITICAL` no Trivy, corrigir e reenviar.

### 2. Merge em develop
1. Fazer merge do PR aprovado em `develop`.
2. Confirmar execucao sequencial dos jobs `validate`, `security` e `image` na branch de destino.
3. Confirmar push da imagem para ECR com tag semver `vMAJOR.MINOR.PATCH`.
4. Confirmar que o job `promote-dev` criou o Pull Request que atualiza o values do microsservico.

### 3. Pós-deploy
1. Confirmar sincronizacao no ArgoCD.
2. Confirmar rollout do deployment atualizado no namespace do microsservico.
3. Validar health endpoint da API.

## Comandos de apoio

```bash
# Verificar workflows no repositório
ls .github/workflows
```

## Troubleshooting
- Falha em OIDC: revisar `AWS_ROLE_TO_ASSUME` e `AWS_REGION`, `permissions: id-token: write`,
  `environment: dev` e o subject permitido na trust policy.
- Falha no push ECR: revisar policy da role de build.
- Falha na promocao GitOps: revisar `GITOPS_TOKEN`, `GITOPS_REPO`, os inputs do workflow e o Pull Request criado.
- Template reutilizavel nao encontrado: publicar os templates no catálogo e habilitar o acesso entre repositorios privados.
- Falha em SAST Python: revisar achados do bandit no diretório do serviço.

## Critério de sucesso
- O workflow correto executa em PR e em `develop`.
- A imagem e enviada ao ECR com tag do commit.
- O Pull Request atualiza o values do microsservico no GitOps com tag e digest.
- O ArgoCD sincroniza a nova imagem sem intervencao manual apos o merge.
