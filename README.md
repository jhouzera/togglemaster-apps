# togglemaster-apps

Repositorio dedicado ao codigo-fonte dos microsservicos ToggleMaster.

Proposito:
- Concentrar exclusivamente o ciclo de desenvolvimento e integracao continua dos microsservicos.
- Publicar imagens versionadas no ECR.
- Promover imagens do ambiente `dev` por Pull Request no repositorio GitOps.

Responsabilidades:
- Codigo das APIs auth, flag, targeting, evaluation e analytics.
- Dockerfiles por servico.
- Workflows adaptadores por microsservico, responsáveis somente por gatilhos e parâmetros.

Pipeline DevSecOps:
- O workflow reutilizável é mantido no repositório `togglemaster-cicd-templates`.
- Pipeline multiestágio com validação, segurança e imagem.
- Pipeline com build, teste, lint, Trivy, gosec, bandit e SonarCloud opcional.
- Push de imagens para o Amazon ECR em commits na branch `develop`, usando tags semver geradas pelo workflow.
- Apos o push, o workflow coleta o digest imutavel e abre um Pull Request que atualiza o values dedicado no repositorio GitOps.
- O job de promocao usa `GITOPS_TOKEN` e `GITOPS_REPO` somente para criar o Pull Request no GitOps.
- O catálogo é referenciado por `@main` até a publicação da primeira tag estável `v1`.
- Checklist operacional no ambiente dev: `docs/CHECKLIST-DEV.md`.
- Runbook operacional no ambiente dev: `docs/RUNBOOK-DEV.md`.

Este repositorio nao deve conter manifests de deploy nem infraestrutura AWS.

Dependencias externas:
- Consome infraestrutura criada pelo `togglemaster-iac`.
- Publica imagens no ECR seguindo o prefixo `togglemaster-dev/*`.
- A promocao para o cluster e declarada no GitOps e reconciliada pelo ArgoCD.
- As variáveis `AWS_ROLE_TO_ASSUME` e `AWS_REGION` devem ser criadas dentro do GitHub Environment (ex: `dev`) e apontar para o output `ecr_role_arns["dev"]` do
	bootstrap de IAM.
- Os secrets de runtime devem seguir o padrao `togglemaster-dev/app/<secret-name>` no AWS Secrets Manager.

Um push aprovado em `develop` publica a imagem e cria a proposta de promocao no GitOps.

