# R_básico é um aplicativo Shiny para realização de análises
# estatísticas básicas
# Autor: Renato Rodrigues Silva
# Licenciado sob a GNU General Public License v3.0

# Este programa é software livre: você pode redistribuí-lo e/ou
# modificá-lo sob os termos da Licença Pública Geral GNU publicada
# pela Free Software Foundation, na versão 3 da Licença, ou
# (a seu critério) qualquer versão posterior.

# Este programa é distribuído na expectativa de que seja útil,
# mas SEM NENHUMA GARANTIA; nem mesmo a garantia implícita de
# COMERCIABILIDADE OU ADEQUAÇÃO A UM DETERMINADO PROPÓSITO.
# Veja a Licença Pública Geral GNU para mais detalhes.

# Você deve ter recebido uma cópia da Licença Pública Geral GNU
# junto com este programa. Caso contrário, veja <https://www.gnu.org/licenses/>.

library(shiny)
library(shinyWidgets)
library(shinythemes)

# UI ---------------------------------------------------------------------
ui <- navbarPage(
  title = "Estatística Básica com R",
  theme = shinytheme("united"),
  
  tabPanel("Importar Dados",
    sidebarLayout(
      sidebarPanel(
        fileInput(
          "arquivo", 
          "Escolha um arquivo CSV ou Excel", 
           accept = c(".csv", ".xlsx")
        ),
        checkboxInput(
          "cabecalho", 
          "Usar cabeçalho", TRUE
        ),
        selectInput(
          "sep", "Separador", 
           multiple = FALSE,
           choices = c('Vírgula' = ",", 
                       'Ponto e Vírgula' = ";", 
                       'Tabulação' = "\t"), 
           selected = ";"
        )
      ),
      mainPanel(
        DT::dataTableOutput("tabela_dados")
      )
    )
  ),
  
  tabPanel("Medidas Resumo",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          #Insere um marcador de posição no seu uiarquivo 
          #Assim, o código do seu servidor preencherá posteriormente.
          uiOutput("ui_variaveis")
        ),
        mainPanel(
          DT::dataTableOutput("resumo")
        )
      )
    )
  ),
  
  tabPanel("Comparação de Variâncias de Duas Populações",
           fluidPage(
             sidebarLayout(
               sidebarPanel(
                 uiOutput("ui_variavel_testeFVar"),
                 uiOutput("ui_variavel_filtroFVar"),
                 uiOutput("ui_valor_filtroFVar"),
                 actionButton(inputId="testeFVar", 
                              label="Teste F para Comparar Variância" 
                              )
               ),
               mainPanel(
                 DT::dataTableOutput("testeFVar")
               )
             )
           )
  ),
  
  
  tabPanel("Comparação de Médias de Duas Populações",
           fluidPage(
             sidebarLayout(
               sidebarPanel(
                 uiOutput("ui_variavel_testes2pop"),
                 uiOutput("ui_variavel_filtro"),
                 uiOutput("ui_valor_filtro"),
                 radioButtons("testes2", 
                              "Escolha o teste apropriado", 
                              choices = c(
                                "Variâncias desiguais" = "var_desiguais",
                                "Variâncias iguais" = "var_iguais", 
                                "Populações dependentes" = "pop_dependentes"
                              )),
                 radioButtons("hipotese_alternativa",
                              "Hipótese alternativa",
                              choices = c(
                                "Bilateral" = "two.sided",
                                "Unilateral à Direita" = "greater", 
                                "Unilateral à Esquerda" = "less"
                              ),
                              selected = "two.sided")
               ),
               mainPanel(
                 DT::dataTableOutput("testes2")
               )
             )
           )
  ),
  
  tabPanel("Análise de Regressão",
           fluidPage(
             sidebarLayout(
               sidebarPanel(
                 textAreaInput("modelo_lm", "Modelo Regressão", 
                               placeholder = "Ex: y ~ x1 + x2 + x3", rows = 15),
                 actionButton("rodar_lm", "Rodar Análise de Regressão")
               ),
               mainPanel(
                 verbatimTextOutput("resultado_lm")
               )
             )
           )),
  
  tabPanel("Referências",
    fluidPage(
      h6('DEEPSEEK. DeepSeek: AI assistant model. 
          Pequim, China: DeepSeek Company, 2024. 
          Disponível em: https://www.deepseek.com/. 
          Acesso em: 08 nov. 2025.'), 
       h6('R CORE TEAM. R: A Language and Environment for 
          Statistical Computing. Vienna, Austria: R Foundation 
          for Statistical Computing, 2024. Versão 4.4.1. 
          Disponível em: https://www.R-project.org/. 
          Acesso em: 08 nov. 2025.'),
       #h6('SÃO PAULO (Estado). 
        #  Secretaria da Educação.Dados da Educação - SP. 
        #  São Paulo, [2025]. 
        #  Disponível em: https://dados.educacao.sp.gov.br/. 
        #  Acesso em: 08 nov. 2025.'),
      h6('XIE, Y.; CHENG, J.; TAN, X. DT: 
          A Wrapper of the JavaScript Library DataTables. 
          Versão 0.33.3. [S. l.]: RStudio, 2025. 
          Pacote R. Disponível em: https://github.com/rstudio/dt. 
          Acesso em: 08 nov. 2025.'),
      h6('WICKHAM, H.; AVERICK, M.; BRYAN, J.; CHANG, W.; MCGOWAN, 
          L. D.; FRANÇOIS, R. et al. Welcome to the tidyverse. 
          Journal of Open Source Software, v. 4, n. 43, p. 1686, 
          2019. DOI: https://doi.org/10.21105/joss.01686.'),
      em('Esse software foi escrito com auxílio de inteligência artificial
      DeepSeek (Deepseek, 2025).')
      )
  )
)  
  
  
  
  


# Server -----------------------------------------------------------------
server <- function(input, output, session) {
  
  # Reativo: ler dados
  dados <- reactive({
    req(input$arquivo)
    ext <- tools::file_ext(input$arquivo$name)
    if (ext == "csv") {
      read.csv(input$arquivo$datapath, 
               header = input$cabecalho, 
               sep = input$sep,
               stringsAsFactors = TRUE)
    } else if (ext == "xlsx") {
      readxl::read_excel(input$arquivo$datapath)
    } else {
      validate("Formato não suportado")
    }
  })
  
  # Exibir dados
  output$tabela_dados <- DT::renderDataTable({
    req(dados())
    DT::datatable(dados())
  })
  
  # Atualizando o menu de variáveis
  output$ui_variaveis <- renderUI({
    req(dados())
    radioButtons(
      inputId = "variaveis",
      label = "Selecione a variável",
      choices = names(dados()),
      selected = names(dados())[1]
    )
  })

  #Obtendo medidas resumos
  output$resumo <- DT::renderDataTable({
    req(dados(), input$variaveis) 
    variavel <- dados()[[input$variaveis]]
    
    # Informações básicas
    inf_basica <- data.frame(
      Descrição = c("Número de observações", "Valores faltantes"),
      Valor = c(length(variavel), sum(is.na(variavel)))
    )
    
    if(is.numeric(variavel)){
      med_resumos = data.frame(
        Descrição= c("Média", 
                             "Desvio Padrão", 
                             "Mínimo", 
                             "1º Quartil", 
                             "Mediana", 
                             "3º Quartil", 
                             "Máximo"),
        Valor = c(
          mean(variavel, na.rm = TRUE),
          sd(variavel, na.rm = TRUE),
          min(variavel, na.rm = TRUE),
          quantile(variavel, 0.25, na.rm = TRUE),
          median(variavel, na.rm = TRUE),
          quantile(variavel, 0.75, na.rm = TRUE),
          max(variavel, na.rm = TRUE))
        )
    } else{
      tab <- table(variavel)
      med_resumos <- data.frame(
        Descrição = as.character(names(tab)),
        Valor = as.vector(tab)
      ) 
    }
    resultado = rbind(inf_basica, med_resumos)  
    DT::datatable(resultado, 
                  options = list(dom = 't', pageLength = 15)
                  )
  })
  
  #UI para definir a variavel de teste de hipoteses
  output$ui_variavel_testes2pop <- renderUI({
    req(dados())
    selectInput(
      inputId = "variavel_mensurada",
      label = "Selecione a variável mensurada",
      choices = names(dados()),
      selected = names(dados())[1]
    )
  })
  
  # UI para variável de filtro
  output$ui_variavel_filtro <- renderUI({
    req(dados())
    selectInput(
      "variavel_filtro",
      "Variável usada como filtro:",
      choices = names(dados())
    )
  })
  
  # UI para valores do filtro
  output$ui_valor_filtro <- renderUI({
    req(input$variavel_filtro, dados())
    
    variavel <- dados()[[input$variavel_filtro]]
    
    if (!is.numeric(variavel)) {
      pickerInput(
        "valores_filtros",
        "Selecione EXATAMENTE 2 categorias:",
        choices = unique(variavel),
        multiple = TRUE,
        options = list(
          "max-options" = 2,      # Máximo 2 seleções
          "max-options-text" = "Máximo 2 variáveis selecionadas"
        )
      )
    } else {
      stop("Erro, o filtro tem que níveis de uma variável categórica")
    }
  })

  
  #UI para definir a variavel de teste de hipoteses
  output$ui_variavel_testeFVar <- renderUI({
    req(dados())
    selectInput(
      inputId = "variavel_mensuradaFVar",
      label = "Selecione a variável mensurada",
      choices = names(dados()),
      selected = names(dados())[1]
    )
  })
  
  # UI para variável de filtro
  output$ui_variavel_filtroFVar <- renderUI({
    req(dados())
    selectInput(
      "variavel_filtroFVar",
      "Variável usada como filtro:",
      choices = names(dados())
    )
  })
  
  # UI para valores do filtro
  output$ui_valor_filtroFVar <- renderUI({
    req(input$variavel_filtroFVar, dados())
    
    variavel <- dados()[[input$variavel_filtroFVar]]
    
    if (!is.numeric(variavel)) {
      pickerInput(
        "valores_filtrosFVar",
        "Selecione EXATAMENTE 2 categorias:",
        choices = unique(variavel),
        multiple = TRUE,
        options = list(
          "max-options" = 2,      # Máximo 2 seleções
          "max-options-text" = "Máximo 2 variáveis selecionadas"
        )
      )
    } else {
      stop("Erro, o filtro tem que níveis de uma variável categórica")
    }
  })
  
  
  

  
  # Resultado da Comparação de Variâncias de Duas Pop
  # Criar um reactive para o teste F que depende do botão
  testeFVar_resultado <- eventReactive(input$testeFVar, {
    req(dados(), 
        input$variavel_mensuradaFVar,
        input$variavel_filtroFVar,
        input$valores_filtrosFVar,  
        length(input$valores_filtrosFVar) == 2
    )
    
    dados_filtro1 <- dplyr::filter(dados(), 
                                   .data[[input$variavel_filtroFVar]] 
                                   == input$valores_filtrosFVar[1]
    )
    dados_filtro2 <- dplyr::filter(dados(), 
                                   .data[[input$variavel_filtroFVar]] 
                                   == input$valores_filtrosFVar[2]
    )
    
    var1 <- dados_filtro1[[input$variavel_mensuradaFVar]]
    var2 <- dados_filtro2[[input$variavel_mensuradaFVar]]
    
    # Remover NAs
    var1 <- na.omit(var1)
    var2 <- na.omit(var2)
    
    # Verificar se há dados suficientes
    if (length(var1) < 2 || length(var2) < 2) {
      return(data.frame(
        Erro = paste("Dados insuficientes. Grupo", 
                     input$valores_filtrosFVar[1], 
                     "tem", length(var1), "obs; Grupo", 
                     input$valores_filtrosFVar[2],
                     "tem", length(var2), "obs")
      ))
    }
    
    if (!is.numeric(var1) || !is.numeric(var2)) {
      return(data.frame(
        Erro = "A variável mensurada deve ser numérica para teste F"
      ))
    }
    
    resultado_test <- var.test(var1, var2)
    
    data.frame(
      Estatística = c( "statistic", 
                       "p.value", 
                       "method", 
                       "alternative"),
      Valor = c(
        round(resultado_test$statistic, 2),
        round(resultado_test$p.value, 4),
        as.character(resultado_test$method),
        as.character(resultado_test$alternative)
      )
    )
  })
  
  # Output para o teste F
  output$testeFVar <- DT::renderDataTable({
    resultado <- testeFVar_resultado()
    DT::datatable(resultado, rownames = FALSE, options = list(dom = 't', pageLength = 5))
  })
  
  
  # Resultado da Comparação de Médias de Duas Pop
  output$testes2 <- DT::renderDataTable({
    req(dados(), 
        input$testes2,
        input$variavel_mensurada,
        input$variavel_filtro,
        input$valores_filtros,  
        length(input$valores_filtros) == 2,
        input$hipotese_alternativa
    )
    
    
    dados_filtro1 <- dplyr::filter(dados(), 
                                   .data[[input$variavel_filtro]] == input$valores_filtros[1]
    )
    dados_filtro2 <- dplyr::filter(dados(), 
                                   .data[[input$variavel_filtro]] == input$valores_filtros[2]
    )
    
    var1 <- dados_filtro1[[input$variavel_mensurada]]
    var2 <- dados_filtro2[[input$variavel_mensurada]]
    
    # Remover NAs
    var1 <- na.omit(var1)
    var2 <- na.omit(var2)
    
    
    if (length(var1) < 2 || length(var2) < 2) {
      return(DT::datatable(data.frame(
        Erro = paste("Dados insuficientes. Grupo", input$valores_filtros[1], 
                     "tem", length(var1), "obs; Grupo", input$valores_filtros[2],
                     "tem", length(var2), "obs")
      )))
    }
    
    if (!is.numeric(var1) || !is.numeric(var2)) {
      return(DT::datatable(data.frame(
        Erro = "A variável mensurada deve ser numérica para testes t"
      )))
    }
    
    if (input$testes2 == "var_iguais") {
        # Teste t para variâncias iguais
        resultado <- broom::tidy(t.test(var1, var2, 
                            var.equal = TRUE,
                            alternative = input$hipotese_alternativa))
    } else if (input$testes2 == "var_desiguais") {
        # Teste t para variâncias desiguais
        resultado <- broom::tidy(t.test(var1, var2, 
                            var.equal = FALSE,
                            alternative = input$hipotese_alternativa))
    } else if (input$testes2 == "pop_dependentes") {
        # Teste t para amostras dependentes
        resultado <- broom::tidy(t.test(var1, var2, 
                             paired = TRUE,
                             alternative = input$hipotese_alternativa))
    } else {
        stop("Erro")
    } 
    
    resultado <- 
      dplyr::mutate(resultado, dplyr::across(dplyr::where(is.numeric), round, 2))
    
    resultado <- dplyr::select(resultado,
          dplyr::any_of(
                   c('estimate1', 
                    'estimate2', 
                    'statistic', 
                    'p.value',
                    'method', 
                    'alternative')))
    
    DT::datatable(resultado, rownames = FALSE,
                  options = list(dom = 't', pageLength = 5))
      
  })
  
  # CFA
  observeEvent(input$rodar_lm, {
    output$resultado_lm <- renderPrint({
      req(dados(),input$modelo_lm)
      dados_limpos = na.omit(dados()) 
      model_lm = input$modelo_lm
      fit <- lm(formula = model_lm, data = dados_limpos)
      listres = list()
      listres[[1]]= broom::tidy(summary(fit))
      listres[[2]] = summary(fit)
      return(listres)
    })
  })
  
  
}

# Run App ---------------------------------------------------------------
shinyApp(ui = ui, server = server)
