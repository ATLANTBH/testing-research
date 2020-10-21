# Example overview: 
# - how to package nodejs related files into the docker image
# - how to use parent node image which has all pre-installed libs necessary to run nodejs script
# - alpine distro is used to shrink the size of the docker image
FROM node:12-alpine

# Do setup for running script
RUN mkdir -p /mynodeproject
COPY index.js /mynodeproject
COPY package.json /mynodeproject
WORKDIR /mynodeproject
RUN npm install --only=production

# Run script
ENTRYPOINT ["node", "index.js"]