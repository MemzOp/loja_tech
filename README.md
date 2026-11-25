# Atividade de Consultas, Stored Procedures e Views

Repositório com as soluções da atividade acadêmica sobre SQL Stored Procedures e Views.

## 📋 Sumário

- [Estrutura do Projeto](#estrutura-do-projeto)
- [Banco de Dados](#banco-de-dados)
- [Blocos da Atividade](#blocos-da-atividade)
- [Como Executar](#como-executar)
- [Referências](#referências)

## 📁 Estrutura do Projeto

```
atividade-stored-procedures/
├── scripts/
│   ├── 00_schema.sql              # Schema do banco de dados
│   ├── 01_queries.sql             # Bloco 1: Consultas SQL
│   ├── 02_stored_procedures.sql   # Bloco 2: Stored Procedures
│   ├── 03_views.sql               # Bloco 3: Views
│   ├── 04_view_vs_sp.sql          # Bloco 4: View vs Stored Procedure (5 cenários)
│   └── 05_queries_avancadas.sql   # Bloco 5: Consultas Avançadas
└── README.md
```

## 🗄️ Banco de Dados

O schema (`00_schema.sql`) cria as seguintes tabelas:

| Tabela | Descrição |
|--------|-----------|
| `categorias` | Categorias de produtos |
| `clientes` | Clientes da loja |
| `vendedores` | Vendedores com comissão |
| `produtos` | Produtos com estoque e categoria |
| `pedidos` | Pedidos realizados |
| `itens_pedido` | Itens de cada pedido |
| `comissoes` | Registro de comissões calculadas |

### Relacionamentos

- `produtos` → `categorias` (N:1)
- `pedidos` → `clientes` (N:1)
- `pedidos` → `vendedores` (N:1)
- `itens_pedido` → `pedidos` (N:1)
- `itens_pedido` → `produtos` (N:1)
- `comissoes` → `vendedores` (N:1)

## 📚 Blocos da Atividade

### Bloco 1: Consultas SQL (`01_queries.sql`)
Consultas fundamentais usando SELECT, JOINs, subqueries e agregações:
- Listagem de clientes e produtos
- Contagem de pedidos por cliente
- Produtos mais vendidos
- Clientes ativos/inativos
- Ticket médio
- Vendas por categoria
- Relatório completo de vendas

### Bloco 2: Stored Procedures (`02_stored_procedures.sql`)
Procedimentos armazenados com parâmetros, lógica de negócio e transações:
- `sp_inserir_cliente` - Cadastro de cliente
- `sp_inserir_pedido` - Criação de pedido com itens (JSON)
- `sp_atualizar_estoque` - Entrada/saída de estoque com validação
- `sp_relatorio_vendas_periodo` - Relatório por período
- `sp_cancelar_pedido` - Cancelamento com restauração de estoque (cursor)
- `sp_calcular_comissao` - Cálculo de comissão de vendedor
- `sp_buscar_cliente_documento` - Busca por CPF/CNPJ ou RG
- `sp_produtos_estoque_baixo` - Alertas de estoque

### Bloco 3: Views (`03_views.sql`)
Views para simplificar consultas complexas e reutilização:
- `vw_resumo_clientes` - Resumo agregado por cliente
- `vw_produtos_completos` - Produtos com categoria
- `vw_detalhes_pedidos` - Pedidos com cliente e vendedor
- `vw_itens_pedido_completo` - Itens com detalhes do produto
- `vw_vendas_por_mes` - Agregação mensal
- `vw_top_clientes` - Top 10 clientes por valor
- `vw_produtos_mais_vendidos` - Ranking de produtos
- `vw_estoque_critico` - Produtos com estoque baixo
- `vw_performance_vendedores` - Métricas de vendedores
- `vw_relatorio_vendas_completo` - Relatório detalhado

### Bloco 4: View vs Stored Procedure (`04_view_vs_sp.sql`)
Análise de 5 cenários práticos com decisão justificada:

| Cenário | Decisão | Justificativa |
|---------|---------|---------------|
| 1. Relatório mensal de vendas | **VIEW** | Leitura apenas, dados agregados, reutilizável |
| 2. Processar novo pedido | **STORED PROCEDURE** | Transação, validações, efeitos colaterais |
| 3. Catálogo de produtos ativos | **VIEW** | Consulta simples, base para outras queries |
| 4. Comissão mensal complexa | **STORED PROCEDURE** | Regras de negócio complexas, parâmetros, saída |
| 5. Dashboard de clientes VIP | **VIEW** | Agregação para exibição, filtros dinâmicos |

### Bloco 5: Consultas Avançadas (`05_queries_avancadas.sql`)
Técnicas avançadas de SQL:
- Window Functions (NTILE, ROW_NUMBER, SUM OVER, LAG)
- CTEs (Common Table Expressions)
- Análise de Cohort (retenção de clientes)
- Classificação ABC (Pareto 80/20)
- Detecção de clientes inativos
- Comparativo ano a ano (PIVOT simulado)
- Subqueries correlacionadas
- NOT EXISTS para produtos nunca vendidos

> **Nota**: Bloco 6 (Desafio Extra) não foi implementado conforme especificação.

## 🚀 Como Executar

### Pré-requisitos
- MySQL 8.0+ ou MariaDB 10.5+
- Cliente MySQL (Workbench, DBeaver, linha de comando)

### Passos

1. **Criar o banco e tabelas:**
```bash
mysql -u root -p < scripts/00_schema.sql
```

2. **Executar os blocos em ordem:**
```bash
mysql -u root -p loja_db < scripts/01_queries.sql
mysql -u root -p loja_db < scripts/02_stored_procedures.sql
mysql -u root -p loja_db < scripts/03_views.sql
mysql -u root -p loja_db < scripts/04_view_vs_sp.sql
mysql -u root -p loja_db < scripts/05_queries_avancadas.sql
```

3. **Testar uma Stored Procedure:**
```sql
CALL sp_inserir_cliente('Novo Cliente', 'novo@email.com', '11999999999', 'Rua Nova, 100');
CALL sp_relatorio_vendas_periodo('2024-01-01', '2024-12-31');
```

4. **Consultar uma View:**
```sql
SELECT * FROM vw_top_clientes;
SELECT * FROM vw_vendas_por_mes WHERE ano = 2024;
```

## 📖 Referências

- **IA** - Assistência de inteligência artificial para estruturação e validação
- **W3Schools SQL Tutorial** - https://www.w3schools.com/sql/
- **Stack Overflow** - Comunidade de desenvolvedores para dúvidas específicas

---

*Atividade acadêmica - Curso de Banco de Dados*