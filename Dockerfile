FROM node:20.19.6-alpine AS build
WORKDIR /opt/server
COPY package.json .
COPY *.js .
RUN npm install


FROM node:20.19.6-alpine
WORKDIR /opt/server
# addgroup -S roboshop ==> it creates system group roboshop foe not running as root so creating this 
# -S flag means “system group” (with a lower GID, typically reserved for system accounts).

# adduser -S roboshop G roboshop  ==> it creates system user and assigninng to roboshop group which I created
#Changes ownership of the /opt/server directory (and all files inside, because of -R = recursive) for both user and group
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop && \   
    chown -R roboshop:roboshop /opt/server
EXPOSE 8080
LABEL com.project="roboshop" \
      component="catalogue" \
      creater="Mahaboob"
COPY  --from=build --chown=roboshop:roboshop /opt/server /opt/server
USER roboshop
ENV MONGO="true" \
    MONGO_URL="mongodb://mongodb:27017/catalogue"
CMD ["node", "server.js"]





# Why do this in a Dockerfile?
# Security best practice: Containers should not run as root. Creating a dedicated user (roboshop) prevents accidental or malicious root-level access.

# Consistency: Ensures the application files in /opt/server are owned by the same user that runs the app.

# CI/CD pipelines: Makes deployments safer, especially when multiple services run in the same environment.

