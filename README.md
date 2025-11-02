# Trabalho prático 1 redes

## Introdução

> Esse projeto é baseado em um [template LaTex](https://github.com/JosoeSantos/template-data-analysis-latex)
> criado por mim para desenvolver trabalhos acadêmicos usando hardware e tempo de 
> resposta melhores.
> Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

Esse repositório contém todo o código, resultados e texto desenvolvidos para o trabalho
prático 1 parte 2 da disciplina de Introdução aos sistemas computacionais.

## Obtendo artefatos do trabalho

Os diretórios estão organizados da seguinte forma:

- **data**: Contém as saídas das simulações validadas e as configurações de plot usadas pelo `gnuplot`
- **src**: Contém as duas simulações do software NS3 usadas neste trabalho
- **scripts**: Contém as automações usadas para gerar os plots do trabalho
- **docs/report**: Contém o código fonte do relatório latex desenvolvido
- **relatorio.pdf**: Relatório final do projeto

### Executando as simulações do NS3 

1. Instale e configure o ns3 coforme o [tutorial](https://www.nsnam.org/docs/release/3.46/tutorial/html/index.html)
2. Copie os arquivos em src para `<ns3-dir>/scratch` onde `<ns3-dir>` é o local de instalação do simulador
3. Copie os arquvos `scripts/part1-script.sh` e `scripts/part2-script.sh` para a 
raiz de `<ns3-dir>`
4. De permissão de execução para os scripts conforme seu sistema operacional
5. Execute os scripts ex.: `./part1-script.sh`
6. Veja os resultados em `<ns3-dir>/results`

### Executando scripts separadamente

Para executar os scripts separadamente siga os passos 1 e 2 da seção anterior e os 
execute conforme o tutorial do NS3:

```sh
# pwd -> <ns3-dir>
./ns3 build
./ns3 scratch/part1-script.sh
```

## Passo a passo para rodar o projeto com Vscode

### 1. Clonar o repositório

Clone este repositório usando o comando abaixo:
```sh
git clone <URL_DO_REPOSITORIO>
cd <nome_da_pasta_do_projeto>
```

### 2. Instalar dependências

Certifique-se de ter as seguintes dependências instaladas no seu sistema:

- **Git**: para clonar e versionar o repositório.
- **LaTeX**: distribuição recomendada [TeX Live](https://www.tug.org/texlive/) (Linux/macOS) ou [MikTeX](https://miktex.org/) (Windows).
- **Make**: normalmente já vem instalado em sistemas Unix (Linux/macOS). No Windows, pode ser instalado via [Chocolatey](https://chocolatey.org/) ou [Gow](https://github.com/bmatzelle/gow).


#### Instalação no Ubuntu/Debian:
```sh
sudo apt update
sudo apt install git make texlive-full
```

#### Instalação no macOS (com Homebrew):
```sh
brew install git make mactex
```

#### Instalação no Windows:
- [Git para Windows](https://git-scm.com/download/win)
- [MikTeX](https://miktex.org/download)
- [Make via Chocolatey](https://community.chocolatey.org/packages/make) (opcional)

### Primeira configuração

Execute o comando abaixo para configurar os hooks do git:
```sh
./setup-hooks.sh
```


### 3. Compilar os documentos projeto

Execute o comando abaixo na raiz do documento para gerar o PDF na pasta `build/`:
```sh
make
```
O PDF final será gerado em `build/<nome-do-documento>.pdf`.

Para limpar os arquivos temporários e o PDF gerado:
```sh
make clean
```

## Visual Studio Code: Extensões recomendadas

Ao abrir este projeto no VSCode, você receberá sugestões automáticas de extensões úteis para trabalhar com LaTeX e com a estrutura do repositório. As recomendações ficam no arquivo `.vscode/extensions.json` e incluem, por exemplo:
- **James-Yu.latex-workshop**: suporte completo a LaTeX no VSCode.
- **PKief.material-icon-theme**: ícones de pastas e arquivos mais intuitivos.

Assim, você terá uma experiência de desenvolvimento mais produtiva e integrada.

## Recomendação de IDE

Recomenda-se o uso do Visual Studio Code (VSCode) para desenvolver o projeto.
Para pessoas que tem interesse em usar mais IA recomendo fortemente o uso da IDE
Cursor. Ou pelo menos do github copilot.
