# Use an official OpenJDK runtime with Tomcat as a parent image
FROM tomcat:9.0.80-jre11-temurin-jammy

# Set the working directory in the container
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file from your Jenkins workspace (which we'll download)
# to the webapps directory in the container.
# The WAR will be automatically exploded and served by Tomcat at /hello-world
COPY hello-world-war-1.1.4.war /usr/local/tomcat/webapps/hello-world.war

# Expose port 8080 (Tomcat's default)
EXPOSE 8080

# Command to run Tomcat (default command for tomcat image)
CMD ["catalina.sh", "run"]