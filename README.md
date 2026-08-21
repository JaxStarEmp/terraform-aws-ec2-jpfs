# Módulo Terraform AWS EC2

Este módulo cria uma ou mais instâncias EC2 na AWS usando a imagem mais recente
do Ubuntu para cada configuração informada em `instances`.

## O que o módulo cria

- `aws_instance.ec2`: uma instância EC2 para cada entrada de `instances`
- `aws_instance.database`: instâncias EC2 para banco, criadas condicionalmente
- `data.aws_ami.ubuntu`: busca uma AMI do Ubuntu da Canonical para cada entrada
- `ebs_block_device`: configura o disco raiz de cada instância como `gp3`
- Suporte a `extra_volumes`: permite anexar discos extras por instância
- Tag `Name` no formato: `${ec2_name}-${env}`
- Tag `Name` da instância de banco no formato: `${ec2_name}-db-${env}`

## Requisitos

- Terraform com provider AWS `~> 6.0`
- Credenciais AWS configuradas
- Região AWS definida no provider

## Entradas (variáveis)

| Nome | Descrição | Tipo | Obrigatório | Padrão |
|------|-----------|------|-------------|--------|
| `env` | Ambiente de deploy (ex.: dev, staging, prod) | `string` | Sim | - |
| `instances` | Mapa com as configurações das instâncias EC2 | `map(object)` | Sim | - |

Cada entrada de `instances` deve informar `ec2_name`. Os demais atributos são
opcionais e possuem os seguintes padrões:

| Atributo | Descrição | Tipo | Padrão |
|----------|-----------|------|--------|
| `ec2_name` | Nome base da EC2 | `string` | - |
| `ec2_type` | Tipo da instância EC2 | `string` | `t3.micro` |
| `ec2_volume_size` | Tamanho do volume do disco raiz em GB | `number` | `10` |
| `ubuntu_version` | Versão do Ubuntu a ser buscada na AMI | `string` | `24.04` |
| `create_database` | Habilita a criação da instância de banco para esta chave | `bool` | `false` |
| `extra_volumes` | Lista de volumes adicionais anexados à instância | `list(object)` | `[]` |

Cada item de `extra_volumes` deve seguir este formato:

```hcl
extra_volumes = [
  {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    volume_size           = 50
  }
]
```

### Observações

- A AMI é pesquisada com filtro no padrão `ubuntu/images/hvm-ssd-gp3/ubuntu-*${ubuntu_version}*-amd64-server-*`
- A imagem é adquirida do owner `099720109477` (Canonical)
- A instância usa a AMI encontrada automaticamente e não um ID fixo
- O disco raiz é configurado como `gp3`, com `delete_on_termination = true` e volume de tamanho variável
- Os volumes extra podem ser informados em `extra_volumes` e serão anexados conforme a configuração de cada instância
- Uma instância de banco só é criada quando `env = "prd"` e a flag `instances.<chave>.create_database` está como `true`
- Em ambientes diferentes de `prd`, as instâncias de banco não são criadas
- As chaves de `instances` identificam cada instância nos recursos e outputs

## Outputs

| Nome | Descrição |
|------|-----------|
| `ec2_id` | Mapa de chaves e IDs das instâncias EC2 |
| `ec2_ip` | Mapa de chaves e IPs públicos das instâncias EC2 |
| `ec2_name` | Mapa de chaves e nomes conforme a tag `Name` |
| `ec2_ami` | Mapa de chaves e IDs das AMIs utilizadas |

## Exemplo de uso

```hcl
provider "aws" {
  region = "us-east-1"
}

module "computer" {
  source = "./"

  env = "dev"

  instances = {
    app = {
      ec2_name        = "meu-servidor"
      ec2_type        = "t3.small"
      ec2_volume_size = 20
      ubuntu_version  = "24.04"
      create_database = false
      extra_volumes = [
        {
          delete_on_termination = true
          device_name           = "/dev/sdb"
          volume_size           = 50
        }
      ]
    }
  }
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

  env = "prod"

  instances = {
    app = {
      ec2_name        = "aplicacao-prod"
      ec2_type        = "t3.micro"
      ec2_volume_size = 30
      ubuntu_version  = "24.04"
      create_database = false
    }
  }
}
```

Para criar a instância de banco, use `env = "prd"` e habilite a flag
`create_database` dentro da entrada da instância:

```hcl
module "computer" {
  source = "../linuxtips-descomplicando-terraform-module-aws-ec2"

  env = "prd"

  instances = {
    app = {
      ec2_name        = "aplicacao"
      ec2_type        = "t3.micro"
      ec2_volume_size = 30
      ubuntu_version  = "24.04"
      create_database = true
    }
  }
}
```

A instância de banco receberá a tag `Name = "aplicacao-db-prd"`.

## Dica

Para alterar a versão do Ubuntu, ajuste `ubuntu_version` dentro da entrada da
instância em `instances`; para aumentar o disco raiz, ajuste `ec2_volume_size`.
Para anexar discos extras, use `extra_volumes` em cada item do mapa `instances`.
O módulo buscará automaticamente a AMI correta para a versão informada.

## Atualizar Tags

Para publicar uma nova versão do módulo no Git, crie uma tag anotada com a versão
correspondente e envie essa tag para o repositório remoto.

```bash
# Verifica o estado atual do repositório
git status

# Cria uma tag anotada com a versão desejada
git tag -a v1.2.3 -m "Release v1.2.3"

# Envia somente a tag criada para o remoto
git push origin v1.2.3

# Ou envia todas as tags locais para o remoto
git push origin --tags
```

Dica: use um padrão consistente para as versões, como `v1.2.3`, para facilitar o
controle de releases. Se a tag for criada por engano, ela pode ser removida localmente
ou no remoto com os comandos abaixo:

```bash
# Remove a tag local
git tag -d v1.2.3

# Remove a tag no repositório remoto
git push origin --delete v1.2.3
```

Também é possível listar as tags existentes com:

```bash
git tag
```