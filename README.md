# Módulo Computer

Este módulo Terraform cria uma instância EC2 na AWS com Ubuntu 22.04 LTS.

## Recursos Criados

- **aws_instance** - Instância EC2 com Ubuntu 22.04 (Jammy)

## Variáveis

| Nome | Descrição | Tipo | Obrigatório | Padrão |
|------|-----------|------|-------------|--------|
| `ec2_name` | Nome base da instância EC2 | `string` | Sim | - |
| `ec2_type` | Tipo da instância EC2 | `string` | Não | `t3.micro` |
| `env` | Ambiente de deploy (ex: dev, staging, prod) | `string` | Sim | - |

## Outputs

| Nome | Descrição |
|------|-----------|
| `ec2_id` | ID da instância EC2 |
| `ec2_ip` | IP público da instância EC2 |
| `ec2_name` | Nome completo da instância (formato: `{ec2_name}-{env}`) |

## Exemplo de Uso

```hcl
module "computer" {
  source  = "./modules/computer"
  
  ec2_name = "meu-servidor"
  ec2_type = "t3.small"
  env      = "dev"
}
```

## Requisitos

- Terraform >= 1.0
- Provider AWS ~> 6.0
- Credenciais AWS configuradas (via variáveis de ambiente, profile ou IAM role)

## AMI Utilizada

O módulo busca automaticamente a AMI mais recente do **Ubuntu 22.04 LTS (Jammy)** para arquitetura `amd64` com virtualização HVM, publicada pela Canonical (owner ID: `099720109477`).

## Tags

A instância recebe a tag `Name` no formato: `{ec2_name}-{env}`

Exemplo: `meu-servidor-dev`