# togglemaster-apps

Repositorio dedicado ao codigo-fonte dos microsservicos ToggleMaster.

Proposito:
- Concentrar exclusivamente o ciclo de desenvolvimento e integracao continua dos microsservicos.
- Publicar imagens versionadas no ECR.
- Publicar releases semver no ECR para promoção pelo ArgoCD Image Updater.

Responsabilidades:
- Codigo das APIs auth, flag, targeting, evaluation e analytics.
- Dockerfiles por servico.
- Workflows adaptadores por microsservico, responsáveis somente por gatilhos e parâmetros.

Pipeline DevSecOps:
- O workflow reutilizável é mantido no repositório `togglemaster-cicd-templates`.
- Pipeline multiestágio com validação, segurança e imagem.
- Pipeline com build, teste, lint, Trivy, gosec, bandit e SonarCloud opcional.
- Push de imagens para o Amazon ECR somente em tags Git `vMAJOR.MINOR.PATCH`.
- O ArgoCD Image Updater observa as tags semanticas no ECR e atualiza o values.yaml dedicado no repositorio GitOps.
- O write-back no GitOps e executado pelo ArgoCD Image Updater; o pipeline de apps nao precisa
	de `GITOPS_TOKEN`, `GITOPS_REPO` ou `GITOPS_BRANCH` no fluxo recomendado.
- O catálogo é referenciado por `@main` até a publicação da primeira tag estável `v1`.
- Checklist operacional no ambiente dev: `docs/CHECKLIST-DEV.md`.
- Runbook operacional no ambiente dev: `docs/RUNBOOK-DEV.md`.

Este repositorio nao deve conter manifests de deploy nem infraestrutura AWS.

Dependencias externas:
- Consome infraestrutura criada pelo `togglemaster-iac`.
- Publica imagens no ECR seguindo o prefixo `togglemaster-dev/*`.
- A promocao para o cluster e feita pelo ArgoCD Image Updater.
- A variable `AWS_ROLE_TO_ASSUME_DEV` deve apontar para o output `ecr_role_arns["dev"]` do
	bootstrap de IAM.
- Os secrets de runtime devem seguir o padrao `togglemaster-dev/app/<secret-name>` no AWS Secrets Manager.

Para publicar uma versao, crie uma tag semantica apontando para o commit desejado, por exemplo:

```bash
git tag v1.0.0
git push origin v1.0.0
```
