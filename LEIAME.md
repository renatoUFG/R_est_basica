# R_est_basica um aplicativo shiny para análise estatísticas básicas
Este aplicativo Shiny facilita a análise  estatísticas básicas
Desenvolvido por **Renato Rodrigues Silva**, utiliza diversas bibliotecas da linguagem R, incluindo `broom`, `tidyverse`  entre outras.

##  Pacotes necessários

- shiny
- shinyWidgets
- shinythemes
- tidyverse
- DT
- broom



##  Instalação

Para usar o aplicativo, é necessário ter o R instalado. Instale as dependências com o script:

```r
source("install_dependencies.R")
```

## Tipo de arquivos aceitos pelo app

Apenas arquivos com extensão .csv ou .xls, ou xlsx são aceitos no app



##  Como executar

### Usando a IDE RStudio

Abra o arquivo `app.R` no RStudio e clique em **Run App**.

### Usando o terminal do Windows

1. Abra o Prompt de Comando (cmd.exe) ou PowerShell.
2. Navegue até a pasta onde está app.R
3. Execute: Rscript app.R

Obs: Se ao rodar Rscript você receber erro do tipo “comando não encontrado”, verifique se o R está no seu PATH do sistema.:

### Usando o terminal linux/macOS

1. Abra o terminal.
2. Vá até a pasta 
3. Execute:  Rscript app.R

### Usando arquivo executável no Windows

Clique  duas vezes nesse .bat, o app será executado automaticamente.

### Usando arquivo executável no Linux/MacOS

1. Abra o terminal
2. Vá até a pasta 
3.  Execute:
a. Somente na primeira vez, para tornar executável
chmod +x rodar_app.sh  
b. Nas outras vezes, execute:
./rodar_app.sh

##Utilização de R_est_basica

A maioria das análises é intuitiva, basta clicar nos botões indicados. 
Para fazer análise de regressão, a sintaxe é a mesma utilizada na função lm do software R,


##  Licença

Este projeto está licenciado sob os termos da **GNU General Public License v3.0 (GPL-3)**.  
Consulte o cabeçalho do arquivo `app.R` ou o arquivo `LICENSE` para mais informações.
