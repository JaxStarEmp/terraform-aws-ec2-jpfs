# Módulo Terraform AWS EC2

Este módulo cria uma instância EC2 na AWS usando a imagem mais recente do Ubuntu, com base na versão informada pela variável `ubuntu_version`.

## O que o módulo cria

- `aws_instance.ec2`: instância EC2
- `data.aws_ami.ubuntu`: busca automaticamente a AMI do Ubuntu da Canonical
- `ebs_block_device`: configura o disco raiz da instância com tipo `gp3` e tamanho definido por `ec2_volume_size`
- Tag `Name` no formato: `${ec2_name}-${env}`

## Requisitos

- Terraform com provider AWS `~> 6.0`
- Credenciais AWS configuradas
- Região AWS definida no provider

## Entradas (variáveis)

| Nome | Descrição | Tipo | Obrigatório | Padrão |
|------|-----------|------|-------------|--------|
| `ec2_name` | Nome base da EC2 | `string` | Sim | - |
| `ec2_type` | Tipo da instância EC2 | `string` | Não | `t3.micro` |
| `ec2_volume_size` | Tamanho do volume do disco raiz em GB | `number` | Não | `10` |
| `ubuntu_version` | Versão do Ubuntu a ser buscada na AMI | `string` | Não | `24.04` |
| `env` | Ambiente de deploy (ex.: dev, staging, prod) | `string` | Sim | - |

### Observações

- A AMI é pesquisada com filtro no padrão `ubuntu/images/hvm-ssd-gp3/ubuntu-*${ubuntu_version}*-amd64-server-*`
- A imagem é adquirida do owner `099720109477` (Canonical)
- A instância usa a AMI encontrada automaticamente e não um ID fixo
- O disco raiz é configurado como `gp3`, com `delete_on_termination = true` e volume de tamanho variável

## Outputs

| Nome | Descrição |
|------|-----------|
| `ec2_id` | ID da instância EC2 |
| `ec2_ip` | IP público da EC2 |
| `ec2_name` | Nome da EC2 conforme a tag `Name` |
| `ec2_ami` | ID da AMI utilizada pela instância |

## Exemplo de uso

```hcl
provider "aws" {
  region = "us-east-1"
}

module "computer" {
  source = "./"

  ec2_name        = "meu-servidor"
  ec2_type        = "t3.small"
  ec2_volume_size = 20
  ubuntu_version  = "24.04"
  env             = "dev"
}

output "instance_id" {
  value = module.computer.ec2_id
}

output "public_ip" {
  value = module.computer.ec2_ip
}
```

### Resultado esperado

A instância criada receberá a tag:

```hcl
Name = "meu-servidor-dev"
```

Além disso, o volume raiz será criado com:

```hcl
volume_type = "gp3"
volume_size = 20
```

Os outputs ficam disponíveis assim:

```hcl
module.computer.ec2_id
module.computer.ec2_ip
module.computer.ec2_name
module.computer.ec2_ami
```

## Exemplo de utilização em outro módulo

```hcl
module "computer" {
  source = "../linuxtips-descomplicando-terraform-module-aws-ec2"

  ec2_name        = "aplicacao-prod"
  ec2_type        = "t3.micro"
  ec2_volume_size = 30
  ubuntu_version  = "24.04"
  env             = "prod"
}
```

## Dica

Para alterar a versão do Ubuntu, ajuste a variável `ubuntu_version`; para aumentar o disco da EC2, ajuste `ec2_volume_size`. O módulo buscará automaticamente a AMI correta para a versão informada.