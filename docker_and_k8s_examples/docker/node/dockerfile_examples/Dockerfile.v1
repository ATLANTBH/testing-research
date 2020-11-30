# Example overview: 
# - how to package nodejs related files into the docker image
# - how to use parent node image which has all pre-installed libs necessary to run nodejs script
# - alpine distro is used to shrink the size of the docker image
FROM node:12-alpine

# Create app directory
WORKDIR /usr/src/app

# Do setup for running script
COPY package*.json ./
RUN npm install --only=production

# Copy app source
COPY . .

EXPOSE 8080
CMD [ "npm", "start" ]