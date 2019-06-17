# Bibliotecas ----
install.packages("tidyverse")
install.packages("tabulizer")
install.packages("lubridate")
install.packages("esquisse")
library(tabulizer)
library(tidyverse)
library(lubridate)
library(highcharter)
library(esquisse)

########################################
# Plot de evolução da tarifa em capitais
# Autoria: Haydee Svab
########################################

url <- "http://files.antp.org.br/2018/copia-de-tarifas_2005-a-atual-1.pdf"

cabecalho <- c("Data", "01-06-2005", 
               "01-09-2006", "01-12-2006", 
               "01-05-2007", "01-09-2007", 
               "01-01-2008", "01-04-2008", "01-07-2008", "01-10-2008", 
               "01-01-2009", "01-04-2009", "01-07-2009", "01-10-2009", 
               "01-01-2010", "01-04-2010", "01-07-2010", "01-10-2010", 
               "01-01-2011", "01-04-2011", "01-07-2011", "01-10-2011", 
               "01-01-2012", "01-04-2012", "01-07-2012", "01-10-2012", 
               "01-01-2013", "01-04-2013", "01-07-2013", "01-10-2013", 
               "01-01-2014", "01-04-2014", "01-07-2014", "01-10-2014", 
               "01-01-2015", "01-04-2015", "01-07-2015", "01-10-2015", 
               "01-01-2016", "01-04-2016", "01-07-2016", "01-10-2016", 
               "01-01-2017", "01-04-2017", "01-07-2017", "01-10-2017")

capitais <- c("Rio Branco/AC",
              "Maceió/AL",
              "Macapá/AP",
              "Manaus/AM",
              "Salvador/BA",
              "Fortaleza/CE",
              "Brasília/DF",
              "Vitória/ES",
              "Goiânia/GO",
              "São Luiz/MA",
              "Cuiabá/MT",
              "Campo Grande/MS",
              "Belo Horizonte/MG",
              "Belém/PA",
              "João Pessoa/PB",
              "Curitiba/PR",
              "Recife/PE",
              "Teresina/PI",
              "Natal/RN",
              "Porto Alegre/RS",
              "Rio de Janeiro/RJ",
              "Porto Velho/RO",
              "Boa Vista/RR",
              "Florianópolis/SC",
              "São Paulo/SP",
              "Aracaju/SE",
              "Palmas/TO")

# Extraindo tabela do site, em PDF e transformando em dataframe em que conteudo das células serao char
output <- extract_tables(url, encoding = "UTF-8") %>% as.data.frame(stringsAsFactors = FALSE) 

# Retirando colunas que ficaram repetidas pela extração e junção das tabelas
output <- output[, -c(21,41)]

# Acertando cabeçalho
output[1,] <- cabecalho

# Selecionando capitais e invertendo o df
output1 <- output %>% filter(output[,1] %in% capitais | output[,1] == "Data") %>% t()
class(output1)

# Acertando o cabeçalho e removendo a primeira linha
colnames(output1) <- output1[1, ]
output1 <- output1[-1,]

# Retirando o "R$ " dos valores e transformando em numérico
output1 <- as.data.frame(output1)
class(output1) # lapply so funciona com dataframe, nao funciona com matriz

# Tratando os valores: "R$ ", "R$", trocando vírgula por ponto e transformando em numeric
output1[] <- lapply(output1, gsub, pattern = (" "), replacement = "", fixed = TRUE)
output1[] <- lapply(output1, gsub, pattern = ("R$"), replacement = "", fixed = TRUE)
output1[] <- lapply(output1, gsub, pattern = (","), replacement = ".", fixed = TRUE)
output1[,2:27] <- lapply(output1[,2:27], as.numeric)

# Transformando data em tipo date
output1[,1] <- dmy(output1[,1])

######################################################################
# Graficando as tarifas com ggplot

g <- output1 %>% gather("Cidade", "valor", 2:27) %>%
  ggplot(aes(x = Data, y = valor, color =  Cidade))+
  geom_line()+
  # adicionando título e fonte
  labs(title = "Evolução da Tarifa nas capitais",
       caption = "Fonte: ANTP") +
  scale_x_date(date_labels = "%b'%y", date_breaks = "8 month") +
  scale_y_continuous(breaks = seq(1,0.25))+
  theme_minimal()+ # alterando o tema do gráfico -> ver outros na cheat sheet
  theme(plot.title = element_text(face ="bold"), # título em negrito [color = "red"]
        axis.title = element_blank(), # retirar o nome do label
        axis.text.x = element_text(angle = 90, vjust = -0.22), # vjust é ajuste vertical pra descer o texto
        axis.line.x = element_line("grey85"), # mudando  cor do eixo x
        axis.ticks = element_line("grey85"), # cor dos risquinhos rente ao label
        legend.title = element_blank(),
        legend.position = "bottom", # colocar abaixo
        legend.spacing.y = unit(0.1, "cm"))

g

# Usando esquisse...

# Empilhando (deixando dados em formato tidy)
output2 <- output1 %>% gather("Cidade", "valor", 2:27)
class(output2)

# Clicar em Addins -> ggplot builder


######################################################################
# Graficando usando o ggplotly
plotly::ggplotly(g)


######################################################################
# Graficando usando Hicharter

output3 <- output2[!is.na(output2[,3]),]

hchart(output3, "line", hcaes(x = Data, y = valor, group = Cidade)) %>% 
  hc_title(
    text = "Evolução da Tarifa",
    useHTML = TRUE) %>% 
  hc_tooltip(table = TRUE, sort = TRUE) %>% 
  hc_credits(
    enabled = TRUE,
    text = "Fonte: ANTP",
    href = url) %>% 
  hc_add_theme(
    hc_theme_flatdark(
      chart = list(
        backgroundColor = "transparent",
        divBackgroundImage = "http://www.wired.com/images_blogs/underwire/2013/02/xwing-bg.gif"
      )
    )
  )

# Agora conseguimos selecionar quais capitais (mais de uma ao mesmo tempo, inclusive)

