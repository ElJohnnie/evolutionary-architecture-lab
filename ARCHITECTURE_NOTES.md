# Modular lab - Observacoes Arquiteturais

## Visao Geral

- O projeto segue o estilo de monolito modular com divisao por dominio: Content, Identity e Billing.
- Cada dominio tem organizacao interna por camadas (core, http, persistence), reduzindo acoplamento entre regras de negocio e infraestrutura.
- O modulo raiz atualmente importa Content e Identity.

## Como o sistema provavelmente opera

1. O usuario autentica no modulo Identity (GraphQL).
2. O servico de autenticacao valida credenciais e verifica assinatura ativa via contrato de integracao (`BillingSubscriptionStatusApi`).
3. A implementacao concreta usada no Identity para esse contrato e um cliente HTTP, desacoplando o dominio de Billing.
4. O modulo Content processa ciclo de vida de videos por casos de uso e servicos especializados (processamento, classificacao indicativa, distribuicao).
5. O AuthGuard suporta REST e GraphQL e usa contexto de requisicao via CLS para compartilhar `userId`/token ao longo do request.

## Trade-offs adotados (provaveis)

### 1) Monolito modular

- Vantagens:
  - Fronteiras de dominio claras.
  - Evolucao organizada sem partir direto para microservicos.
- Custos:
  - Mais configuracao de modulo, DI e persistencia.
  - Exige disciplina para nao violar fronteiras.

### 2) Integracao por contrato + adaptador HTTP

- Vantagens:
  - Baixo acoplamento entre dominios.
  - Facilita futura extracao para servico independente.
- Custos:
  - Dependencia de rede (latencia/falhas).
  - Necessidade de observabilidade e tratamento de resiliencia.

### 3) Persistencia isolada por dominio

- Vantagens:
  - Autonomia de schema e evolucao por modulo.
  - Menos risco de acoplamento acidental no banco.
- Custos:
  - Migracoes e operacao mais complexas.
  - Transacoes cross-domain mais delicadas.

### 4) Protocolos mistos (REST + GraphQL)

- Vantagens:
  - Cada dominio usa a interface mais adequada ao seu caso.
- Custos:
  - Operacao e governanca de API ficam mais complexas.
  - Curva de aprendizado maior para o time.

## Design Patterns identificados

- Modular Monolith: separacao por contextos de negocio.
- Dependency Injection / IoC: Nest container com providers e tokens.
- Ports and Adapters (Hexagonal): interface de integracao + implementacao concreta.
- Strategy via DI: adapters trocaveis para capacidades de processamento de video.
- Use Case / Application Service: classes dedicadas a orquestrar fluxo de negocio.
- Repository Pattern: acesso a dados encapsulado por repositorios.
- Facade de infraestrutura: wrappers de Config e HTTP para padronizar acesso externo.
- Request Context (CLS): propagacao de identidade e metadados no ciclo do request.
- Provider Alias no DI (`useExisting`): um contrato aponta para provider concreto ja registrado, evitando duplicacao e mantendo desacoplamento.

## Pontos de atencao observados

- Existe possivel divergencia entre documentacao e implementacao de persistencia: no codigo inspecionado, os modulos de persistencia usam TypeORM.
- Secret JWT aparece hardcoded no modulo de autenticacao (deveria vir de ambiente/secret manager).
- Cliente HTTP de integracao com Billing contem placeholder de token Authorization, sugerindo ajuste pendente para ambiente real.
- Em um caso de uso de Content, o uso de `Promise.all` merece revisao para garantir paralelismo e semantica correta do `await`.

## Recomendacoes objetivas

1. Externalizar segredos e tokens para variaveis de ambiente e/ou secret manager.
2. Alinhar README/guia com o estado real do codigo (ou concluir migracao planejada de ORM, se houver).
3. Padronizar contrato de integracao com timeout, retry e observabilidade.
4. Revisar pontos assincronos criticos (especialmente composicao com `Promise.all`).
5. Evoluir testes E2E para cobrir fluxos intermodulo (Auth -> Billing -> Identity e pipelines de Content).

## Referencias de codigo utilizadas

- src/app.module.ts
- src/main.ts
- src/module/content/content.module.ts
- src/module/content/core/use-case/create-movie.use-case.ts
- src/module/content/core/service/video-processor.service.ts
- src/module/content/persistence/content-persistence.module.ts
- src/module/identity/identity.module.ts
- src/module/identity/core/service/authentication.service.ts
- src/module/identity/http/graphql/user.resolver.ts
- src/module/identity/persistence/identity-persistence.module.ts
- src/module/billing/billing.module.ts
- src/module/billing/core/service/subscription.service.ts
- src/module/billing/http/rest/controller/subscription.controller.ts
- src/module/billing/persistence/billing-persistence.module.ts
- src/module/shared/module/auth/auth.module.ts
- src/module/shared/module/auth/guard/auth.guard.ts
- src/module/shared/module/config/config.module.ts
- src/module/shared/module/config/service/config.service.ts
- src/module/shared/module/http-client/client/http.client.ts
- src/module/shared/module/integration/interface/billing-integration.interface.ts
- src/module/shared/module/integration/client/billing-subscription-http.client.ts
- src/module/shared/module/integration/interface/domain-module-integration.module.ts
