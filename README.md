# togglemaster-apps

Repositório *monorepo* dedicado ao código-fonte dos microsserviços da plataforma ToggleMaster.

## 🎯 Propósito
Concentrar exclusivamente o ciclo de desenvolvimento, testes, análise de segurança e integração contínua (CI) dos microsserviços (Auth, Flag, Targeting, Evaluation, Analytics).

## 🚀 Como Utilizar

Cada pasta dentro de `app/` é um serviço Python independente. O CI do repositório é otimizado com a ferramenta `dorny/paths-filter`, que garante que **apenas o serviço que teve o código modificado** acione o fluxo completo de testes e build, pulando os demais serviços para economizar recursos e tempo.

Ao realizar um *merge* para a branch `main`, o GitHub Actions executa o build da imagem Docker, faz o *push* para o Amazon ECR, e em seguida **abre um Pull Request automatizado no repositório `togglemaster-gitops`** para promover a versão no cluster.

### Exemplo Simples (Execução Local)

```bash
# Navegue até o serviço
cd app/auth-service

# Crie um ambiente virtual (recomendado)
python3 -m venv venv && source venv/bin/activate

# Instale as dependências
pip install -r requirements.txt
pip install -r requirements-test.txt

# Execute os testes unitários
pytest
```

## 🔐 Segurança e Boas Práticas
- **Zero Segredos no Código:** Nenhum *secret* ou senha é *hardcoded*. A plataforma adota a injeção via variáveis de ambiente no Kubernetes que são resgatadas dinamicamente do AWS Secrets Manager.
- Todos os *Pull Requests* passam por um **Quality Gate** via SonarQube e Trivy antes do *merge*.
