FROM debian:bullseye-slim

RUN apt-get update
RUN apt-get install -y openjdk-11-jdk wget curl
# RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
# RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar
# RUN mv apktool_2.4.1.jar apktool.jar
# RUN chmod +x apktool apktool.jar
# RUN mv apktool apktool.jar /usr/local/bin

RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
RUN wget $(curl -s https://api.github.com/repos/iBotPeaches/Apktool/releases/latest | grep 'browser_' | cut -d\" -f4)
RUN mv apktool_*.*.*.jar apktool.jar

WORKDIR /app

COPY clone.sh /app/
RUN chmod +x /app/clone.sh

ENTRYPOINT ["/app/clone.sh"]
