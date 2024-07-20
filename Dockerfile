#https://docs.docker.com/reference/dockerfile/   READ PLEASE
# dockerfile consists of 2 import things.
# 1. Comment 
# 2. Directive
 
#Download ubuntu 20.04
FROM    ubuntu:20.04

# Give label for your docker file 
LABEL   description="This is my first image" \
        maintainer="farrukh sadykov"

# install telnet     
RUN     DEBIAN_FRONTEND=noninteractive  apt-get update -y               &&  \   
        DEBIAN_FRONTEND=noninteractive  apt-get install telnet -y       &&  \
        DEBIAN_FRONTEND=noninteractive  apt-get install  apache2 -y     && \
        apt-get clean

# Open port 80 on container
EXPOSE 80

# Copy file content 
COPY index.html   /var/www/html 


# Run command 
CMD ["apache2ctl", "-D", "FOREGROUND"]


