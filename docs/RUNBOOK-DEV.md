# Runbook de Operacao do Repositorio Apps (Dev)

## Objetivo
Executar o ciclo completo de CI e entrega de imagens para os microsservicos do ToggleMaster no ambiente `dev`.

## Escopo
- Build, teste e lint por microsservico.
- Scans de seguranca (SCA e SAST).
- Geração e publicação de artefatos AIOps no job `validate` (`aiops_test_report.json`, `aiops_test_report.schema.json` e `aiops_test_summary.md`).
- Build/push de imagem no ECR.
- Atualizacao automatica do values correspondente no repositório GitOps.

## Pré-requisitos
- Templates `validate.yml`, `security.yml`, `image.yml` e `update-gitops.yml` publicados no repositório `togglemaster-cicd-templates` e acessíveis pelo GitHub Actions.
- Secrets configurados no repositório `togglemaster-apps`:
  - `SONAR_TOKEN` (opcional)
- Variable `AWS_ROLE_TO_ASSUME_DEV`.
- Roles OIDC de build com permissao de push no ECR.
- O Image Updater possui o token de write-back; o pipeline de apps nao atualiza o GitOps.

## Configuração manual no GitHub

Em `Settings > Secrets and variables > Actions` do repositorio `togglemaster-apps`:

1. Cadastre a variable `AWS_ROLE_TO_ASSUME_DEV` com o ARN da role
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
5. Baixar o artifact `aiops-*` do job `validate` quando houver falha, para inspecionar o resumo estruturado e os logs anexados.
6. Se houver vulnerabilidade `CRITICAL` no Trivy, corrigir e reenviar.

### 2. Merge em main
1. Fazer merge do PR aprovado.
2. Confirmar execucao sequencial dos jobs `validate`, `security` e `image` na branch de destino.
3. Confirmar push da imagem para ECR com tag semver `vMAJOR.MINOR.PATCH`.
4. Confirmar que o ArgoCD Image Updater atualizou o arquivo de values do microsservico.

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
- Falha em OIDC: revisar `AWS_ROLE_TO_ASSUME_DEV`, `permissions: id-token: write`,
  `environment: dev` e o subject permitido na trust policy.
- Falha no push ECR: revisar policy da role de build.
- Falha na promoção GitOps: revisar o pod do Image Updater, `argocd/git-creds`, annotations
  da Application e permissao de escrita na branch `main`.
- Template reutilizavel nao encontrado: publicar os templates no catálogo e habilitar o acesso entre repositorios privados.
- Falha em SAST Python: revisar achados do bandit no diretório do serviço.
- Falha em `validate`: baixar o artifact `aiops-*` do run para revisar `aiops_test_summary.md`, identificar padrões de timeout, rede, dependência ou autenticação e comparar com o baseline anterior.

## Critério de sucesso
- O workflow correto executa em PR e em main.
- A imagem e enviada ao ECR com tag do commit.
- O values do microsservico e atualizado no GitOps automaticamente.
- O ArgoCD sincroniza a nova tag sem intervenção manual.
