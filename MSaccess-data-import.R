# Instalar rJava pelo terminal:
# sudo apt-get install -y default-jre
# sudo apt-get install -y default-jdk
# sudo R CMD javareconf
# (fonte: https://www.r-bloggers.com/installing-rjava-on-ubuntu/)

# Instalando estes 3 pacotes (rJava, xlsx e RODBC) que são requisitos p/ o pacote ImportExport 
install.packages("rJava")
install.packages("xlsx")

# No terminal isntalar: sudo apt-get install unixodbc-dev
# (fonte: https://superuser.com/questions/283272/problem-with-rodbc-installation-in-ubuntu)
install.packages("RODBC")

# Instalando e habilitando pacote ImportExport
# Tutorial do pacote disponíel em: https://cran.r-project.org/web/packages/ImportExport/ImportExport.pdf
install.packages("ImportExport")
library (ImportExport)

# sudo apt-get install mdbtools
access_import("/home/haydee/Documentos/OD-Rio/OD_RMRJ.mdb")

