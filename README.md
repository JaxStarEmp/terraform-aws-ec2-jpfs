# Módulo Terraform AWS EC2

Este módulo cria instâncias EC2 na AWS com base em `instances`, usando Ubuntu por
padrão, suporte a AMI customizada, anexos de volumes extras e criação condicional
de instâncias de banco.

## O que o módulo cria

- `aws_instance.ec2`: uma instância EC2 para cada chave em `instances`
- `aws_instance.database`: instâncias EC2 de banco criadas quando `create_database = true`
- `data.aws_ami.ubuntu`: busca uma AMI Ubuntu da Canonical quando `ami_id` não for informado
- `root_block_device` e `ebs_block_device`: configuração do disco raiz e volumes adicionais
- `metadata_options.http_tokens = "required"`: habilita IMDSv2 para reforçar a segurança
- Tag `Name` no formato `${ec2_name}-${env}`
- Tag `Name` da instância de banco no formato `${ec2_name}-db-${env}`

## Requisitos

- Terraform
- Provider AWS com versão `~> 6.0`
- Credenciais AWS configuradas
- Região AWS definida no provider

## Entradas (variáveis)

| Nome | Descrição | Tipo | Obrigatório | Padrão |
|------|-----------|------|-------------|--------|
| `env` | Ambiente de deploy (ex.: dev, staging, prod) | `string` | Sim | - |
| `instances` | Mapa com as configurações das instâncias EC2 | `map(object)` | Sim | - |

Cada entrada de `instances` deve conter `ec2_name`. Os demais atributos são
opcionais e possuem os seguintes padrões:

| Atributo | Descrição | Tipo | Padrão |
|----------|-----------|------|--------|
| `ec2_name` | Nome base da instância EC2 | `string` | - |
| `ec2_type` | Tipo da instância EC2 | `string` | `t3.micro` |
| `ec2_volume_size` | Tamanho do volume raiz em GB | `number` | `10` |
| `ubuntu_version` | Versão do Ubuntu usada para buscar a AMI | `string` | `24.04` |
| `create_database` | Habilita criação da instância de banco para este item | `bool` | `false` |
| `ami_id` | AMI customizada a ser usada; quando presente, ignora a busca por `ubuntu_version` | `string` | `null` |
| `extra_volumes` | Lista de volumes extras anexados à instância | `list(object)` | `[]` |

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
- Se `ami_id` for informado, ele tem prioridade sobre a AMI buscada automaticamente
- O disco raiz é configurado como `gp3`, criptografado e com `delete_on_termination = true`
- Os volumes extras podem ser informados em `extra_volumes` e serão anexados conforme a configuração de cada instância
- As chaves de `instances` identificam cada instância nos recursos e outputs
- A criação da instância de banco é controlada pela flag `create_database`; no código atual, a lógica não aplica uma restrição por ambiente dentro do próprio módulo

## Outputs

| Nome | Descrição |
|------|-----------|
| `ec2_id` | Mapa com as chaves de `instances` e os IDs das instâncias EC2 |
| `ec2_ip` | Mapa com as chaves de `instances` e os IPs públicos das instâncias EC2 |
| `ec2_name` | Mapa com as chaves de `instances` e os nomes conforme a tag `Name` |
| `ec2_ami` | Mapa com as chaves de `instances` e os IDs das AMIs utilizadas |
| `instances` | Mapa com os dados de cada instância: `id`, `ami` e `ip` |

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
      create_database = true
      ami_id          = null
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

A instância principal criada receberá a tag:

```hcl
Name = "meu-servidor-dev"
```

Se `create_database = true`, também será criada uma instância de banco com a tag:

```hcl
Name = "meu-servidor-db-dev"
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
module.computer.instances
```

Exemplo do conteúdo de `module.computer.instances`:

```hcl
{
  app = {
    id  = "i-0123456789abcdef0"
    ami = "ami-0123456789abcdef0"
    ip  = "54.123.45.67"
  }
}
```

## Exemplo com instância de banco

```hcl
module "computer" {
  source = "../terraform-aws-ec2-jpfs"

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

> Observação: no estado atual do módulo, a criação da instância de banco é controlada somente por `create_database = true`. O valor de `env` continua sendo usado na tag e no nome dos recursos.

## Dica

Para alterar a versão do Ubuntu, ajuste `ubuntu_version` na entrada da instância;
para aumentar o disco raiz, ajuste `ec2_volume_size`; para anexar discos extras,
use `extra_volumes`. Também é possível informar uma AMI específica por meio de
`ami_id` quando a imagem precisa ser fixa ou customizada.

## Atualizar tags

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
controle de releases. Se a tag for criada por engano, ela pode ser removida localmente.
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