# Checklist de Integracao GitHub + Apps (Ambiente Dev)

## 1. Preparacao inicial
- [ ] Confirmar que o repositorio `togglemaster-apps` esta atualizado com os 5 workflows por microsservico.
- [ ] Confirmar que os templates `validate.yml`, `security.yml`, `image.yml` e `update-gitops.yml` existem no catálogo e estao referenciados pelos wrappers.
- [ ] Confirmar que os wrappers encadeiam `validate`, `security` e `image` com `needs`.

## 2. Secrets obrigatorios no repositório
Em `Settings > Environments > dev > Environment variables`:
- [ ] `AWS_ROLE_TO_ASSUME` e `AWS_REGION` definidos como variáveis de ambiente no Environment `dev`.

## 3. Secret opcional recomendado
- [ ] `SONAR_TOKEN` definido para habilitar análise no SonarCloud.

## 4. Role OIDC para ECR
- [ ] Confirmar que o ARN da role no campo `role-to-assume` dos workflows está correto.
- [ ] Confirmar trust policy da role para `token.actions.githubusercontent.com`.
- [ ] Confirmar que a trust policy permite `repo:jhouzera/togglemaster-apps:environment:dev`.
- [ ] Confirmar policy com permissao de login/push no ECR dos repositorios do projeto.

## 5. Configuracoes de GitHub Actions
Em `Settings > Actions > General`:
- [ ] Execucao de workflows permitida.
- [ ] Actions de terceiros permitidas para os provedores usados.
- [ ] `Workflow permissions` compativel com os jobs (read como base).

## 6. Branch protection (recomendado)
Em `Settings > Branches > main`:
- [ ] Exigir Pull Request para merge.
- [ ] Exigir revisão de codigo.
- [ ] Exigir status checks obrigatorios dos workflows por microsservico.
- [ ] Bloquear merge com checks falhando.

## 7. Mapeamento workflow por microsservico
- [ ] `auth-service` -> `.github/workflows/auth-service-ci.yml`.
- [ ] `flag-service` -> `.github/workflows/flag-service-ci.yml`.
- [ ] `targeting-service` -> `.github/workflows/targeting-service-ci.yml`.
- [ ] `evaluation-service` -> `.github/workflows/evaluation-service-ci.yml`.
- [ ] `analytics-service` -> `.github/workflows/analytics-service-ci.yml`.

## 8. Validacao em Pull Request
- [ ] Criar PR alterando apenas `app/auth-service/**`.
- [ ] Confirmar execucao somente do workflow do `auth-service`.
- [ ] Confirmar etapas de build, test, lint, SCA e SAST.
- [ ] Confirmar que vulnerabilidade `CRITICAL` bloqueia o pipeline.

## 9. Validacao na branch develop
- [ ] Fazer merge de PR aprovado na `develop`.
- [ ] Confirmar build da imagem Docker do microsservico alterado.
- [ ] Confirmar scan de imagem com Trivy.
- [ ] Confirmar push para ECR com tag semver `vMAJOR.MINOR.PATCH`.
- [ ] Confirmar a criacao do Pull Request de promocao no `togglemaster-gitops`.
- [ ] Confirmar tag e digest no values em `environments/dev/apps/`.
- [ ] Confirmar sincronizacao automatica no ArgoCD.

## 10. Troubleshooting rapido
- [ ] Falha de OIDC: revisar trust policy da role e ref do workflow.
- [ ] Falha de push ECR: revisar policy anexada na role de build.
- [ ] Falha na promocao GitOps: revisar `GITOPS_TOKEN`, `GITOPS_REPO`, o Pull Request e a protecao
	de branch do repositorio GitOps.
- [ ] Falha em segurança: revisar saída do Trivy, gosec ou bandit e corrigir o código.

## 11. Criterio de pronto
- [ ] Os 5 workflows por microsservico executam em PR e `develop`.
- [ ] Build e push no ECR funcionando para qualquer microsservico alterado.
- [ ] Pull Request de promocao atualiza o arquivo de values no `togglemaster-gitops`.
- [ ] ArgoCD sincroniza a imagem por digest automaticamente no `dev`.
