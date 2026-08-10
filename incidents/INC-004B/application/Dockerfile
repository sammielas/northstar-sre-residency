FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY CacheLeakApp.java .
RUN javac CacheLeakApp.java

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /src/CacheLeakApp*.class /app/
USER 10001
EXPOSE 8080
CMD ["java","-Xms64m","-Xmx256m","CacheLeakApp"]
