# Módulo Terraform AWS EC2

Este módulo cria instâncias EC2 na AWS a partir de um mapa `instances`, com suporte a Ubuntu por padrão, AMI customizada, volume raiz configurado, volumes extras e criação opcional de uma instância de banco.

## O que o módulo cria

- `aws_instance.ec2`: uma instância EC2 para cada chave em `instances`
- `aws_instance.database`: instância adicional criada quando `create_database = true`
- `data.aws_ami.ubuntu`: busca uma AMI Ubuntu da Canonical quando `ami_id` não é informado
- `metadata_options.http_tokens = "required"`: habilita IMDSv2 para reforçar a segurança
- Tag `Name` no formato `${ec2_name}-${env}`
- Tag `Name` da instância de banco no formato `${ec2_name}-db-${env}`

## Requisitos

- Terraform
- Provider AWS compatível com a versão declarada no módulo
- Credenciais AWS configuradas
- Região AWS definida no provider

## Entradas (variáveis)

| Nome | Descrição | Tipo | Obrigatório | Padrão |
|------|-----------|------|-------------|--------|
| `env` | Ambiente de deploy (ex.: dev, staging, prod) | `string` | Sim | - |
| `instances` | Mapa com as configurações das instâncias EC2 | `map(object)` | Sim | - |

Cada item de `instances` deve conter `ec2_name`. Os demais campos são opcionais e possuem os padrões abaixo:

| Atributo | Descrição | Tipo | Padrão |
|----------|-----------|------|--------|
| `ec2_name` | Nome base da instância | `string` | - |
| `ec2_type` | Tipo da instância EC2 | `string` | `t3.micro` |
| `ec2_volume_size` | Tamanho do volume raiz em GB | `number` | `10` |
| `ubuntu_version` | Versão do Ubuntu usada para buscar a AMI | `string` | `24.04` |
| `create_database` | Cria uma instância de banco para esse item | `bool` | `false` |
| `ami_id` | AMI customizada; quando informada, substitui a busca automática | `string` | `null` |
| `extra_volumes` | Lista de volumes extras para anexar | `list(object)` | `[]` |

Cada item de `extra_volumes` aceita o seguinte formato:

```hcl
extra_volumes = [
  {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    volume_size           = 50
  }
]
```

### Observações importantes da implementação atual

- A busca da AMI usa o filtro `ubuntu/images/hvm-ssd-gp3/ubuntu-*${ubuntu_version}*-amd64-server-*`
- O owner da imagem é `099720109477` (Canonical)
- Se `ami_id` for informado, ele tem prioridade sobre a AMI descoberta automaticamente
- O volume raiz é configurado como `gp3` em `/dev/sda1`, criptografado e com `delete_on_termination = true`
- Os volumes extras são anexados por `dynamic "ebs_block_device"` e podem ser definidos por `device_name`
- As chaves do mapa `instances` são usadas como identificadores dos recursos e dos outputs
- A criação da instância de banco é controlada somente por `create_database = true`

## Outputs

| Nome | Descrição |
|------|-----------|
| `ec2_id` | Mapa com as chaves de `instances` e os IDs das instâncias principais |
| `ec2_ip` | Mapa com as chaves de `instances` e os IPs públicos das instâncias principais |
| `ec2_name` | Mapa com as chaves de `instances` e os nomes definidos pela tag `Name` |
| `ec2_ami` | Mapa com as chaves de `instances` e os IDs das AMIs usadas |
| `instances` | Mapa consolidado com `id`, `ami` e `ip` para cada instância principal |

> Observação: a implementação atual não expõe outputs específicos para as instâncias de banco criadas em `aws_instance.database`.

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

A instância principal recebe a tag:

```hcl
Name = "meu-servidor-dev"
```

Se `create_database = true`, também é criada uma instância de banco com a tag:

```hcl
Name = "meu-servidor-db-dev"
```

O volume raiz da instância principal será configurado com a seguinte intenção de uso:

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

Nesse caso, a instância de banco recebe a tag:

```hcl
Name = "aplicacao-db-prd"
```

## Dica de uso

Para alterar a imagem Ubuntu, ajuste `ubuntu_version`; para aumentar o disco raiz, ajuste `ec2_volume_size`; para anexar volumes adicionais, use `extra_volumes`; e para forçar uma AMI específica, informe `ami_id`.

## Publicação de versões

Para publicar uma nova versão do módulo no Git, crie uma tag anotada com a versão correspondente e envie essa tag para o repositório remoto.

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

Se a tag for criada por engano, ela pode ser removida localmente ou no remoto:

```bash
# Remove a tag local
git tag -d v1.2.3

# Remove a tag no repositório remoto
git push origin --delete v1.2.3
```

Também é possível listar tags existentes com:

```bash
git tag
```