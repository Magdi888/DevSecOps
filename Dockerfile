FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup --system java-app && adduser --system java-app -G java-app
COPY ${JAR_FILE} app.jar
USER java-app
ENTRYPOINT ["java","-jar","/app.jar"]