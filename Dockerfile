FROM maven:3.5-jdk-8-alpine as builder
WORKDIR /usr/src/
COPY . /usr/src
RUN mvn package

FROM openjdk:8-jre-alpine

ARG USER=abc
ENV HOME /home/$USER
RUN apk add --update sudo

# add new user
RUN adduser -D $USER

WORKDIR /home/$USER

COPY --from=builder /usr/src/target/lib/jetty-runner.jar .
COPY --from=builder /usr/src/target/*.war server.war
COPY --from=builder /usr/src/src/main/resources/openapi.yaml .
COPY --from=builder /usr/src/inflector.yaml .

RUN chmod -R 777 /home/$USER

USER $USER

EXPOSE 8080

CMD ["java", "-jar", "-DswaggerUrl=openapi.yaml", "/home/abc/jetty-runner.jar", "--log", "/home/abc/yyyy_mm_dd-requests.log", "/home/abc/server.war"]
