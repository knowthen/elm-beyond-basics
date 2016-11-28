# Node Server

## Setup 

1. Install Recent Version of **Nodejs** by downloading and running the installer found at https://nodejs.org/en/ or use the Node Version Manager found at https://github.com/creationix/nvm
2. Install Nodejs dependancies by keying `npm install` from within this directory

## Starting Server

The server can be started by keying `node server.js`

## Where's the data stored?

The runner records are saved into `local.db` file, via [nedb](https://github.com/louischatriot/nedb).  You can manually edit/delete this file and restart the server.

## Where's the username and password?

The app isn't doing real auth... The username and password is stored in the `user` file and it's loaded using [dotenv](https://github.com/motdotla/dotenv)

## Bugs

Yes, there are bugs in the app... Covering every edge case scenario wouldn't make for a good training videos.. We'd have to go off on too many tangents (edge cases), which would be distracting from the main content.
