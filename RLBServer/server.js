const koa = require('koa');
const Promise = require('bluebird');
const router = require('koa-router');
const cors = require('koa-cors');
const koaBody = require('koa-body');
const websockify = require('koa-websocket');
const jwt = require('jsonwebtoken');
const ms = require('ms');
const _ = require('lodash');
const Joi = require('joi');
const repl = require('repl');
const parse = require('yargs')
  .command('time <minute>')
  .parse;
const path = require('path');
const Datastore = require('nedb');
const random = require('random-js')();
const PubSub = require('pubsub-js');
const db = new Datastore(
  { filename: path.join(__dirname, 'local.db'),
    autoload: true,
  });
require('dotenv').config({path: 'user'});
db.insert = Promise.promisify(db.insert);
db.find = Promise.promisify(db.find);
db.update = Promise.promisify(db.update);

const app = koa();
websockify(app);

const wsApi = router();
const api = router();

app.use(cors());

const REPLHELP = 'REPL commands: reset | start | time <minute> | exit';

const RUNNERUPDATE = 'runner update';
const LISTENRUNNERS = 'listen runners';
const NEWRUNNER = 'new runner';
const UPDATERUNNER = 'update runner';
const REMOVERUNNER = 'remove runner';
const JWT_PW = 'secret';


const RUNNERSCHEMA = Joi.object().keys({
  id: Joi.string().optional(),
  name: Joi.string().required(),
  location: Joi.string().required(),
  age: Joi.number().integer().min(1).required(),
  bib: Joi.number().integer().min(1).required(),
  lastMarkerDistance: Joi.number().min(0).required(),
  lastMarkerTime: Joi.number().min(0).required(),
  pace: Joi.number().min(0).required(),
});



app.use(koaBody());

api.post('/runner', isAuth, addRunner);
api.post('/authenticate', authenticate);

function getToken(header) {
  if (header) {
    const elements = header.split(' ');
    if (elements.length === 2) {
      const scheme = elements[0];
      if (scheme === 'Bearer') {
        return elements[1];
      }
    }
  }
  return null;
}

function* isAuth(next) {
  const token = getToken(this.request.get('Authorization'));
  const { valid, err } = verifyToken(JWT_PW, token);
  if (valid) {
    yield next;
  } else {
    this.body = "Invalid Token, Must Login Again!";
    this.status = 401;
  }
}

function newRunner(body) {
  const pace = random.real(0.08, 0.13);
  const runner = Object.assign({ lastMarkerDistance: 0.0, lastMarkerTime: 0.0, pace },
      _.pick(body, ['name', 'location', 'age', 'bib']));
  return runner;
}

function* addRunner() {
  // const pace = random.real(0.08, 0.13);
  // const runner = Object.assign({ lastMarkerDistance: 0.0, lastMarkerTime: 0.0, pace },
  //     _.pick(JSON.parse(this.request.body), ['name', 'location', 'age', 'bib']));
  const runner = newRunner(this.request.body);
  const { error } = Joi.validate(runner, RUNNERSCHEMA);
  if (error) {
    this.body = joiValidationErrorMsg(error);
    this.status = 422;
    return;
    // return this.throw(joiValidationErrorMsg(error), 400);
  }
  try {
    const result = yield db.insert(runner);
    const msg = { name: NEWRUNNER, msg: result };
    PubSub.publish(RUNNERUPDATE, msg);
    this.status = 201;
    this.set('location', result._id);
    this.body = result;
  } catch (err) {
    this.throw(err, 400);
  }
}

function* authenticate() {
  const { username, password } = this.request.body;
  if (username === process.env.USERNAME && password === process.env.PASSWORD) {
    const token = jwt.sign({ id: 1, exp: ms('1 year') }, JWT_PW);
    this.body = { token };
  } else {
    // this.throw('Invalid Username Or Password!', 401);
    this.body = 'Invalid Username Or Password!';
    this.status = 401;
  }
}

wsApi.get('/runners', function* middleware() {
  const tokens = [];
  this.websocket.on('message', (message) => {
    const msg = JSON.parse(message);
    if (msg.name === LISTENRUNNERS){
      const token = listenRunners(this.websocket, msg);
      tokens.push(token);
    }
  });

  this.websocket.on('close', () => {
    tokens.forEach( token => {
      PubSub.unsubscribe(token);
    })
  });
});


function formatMessage(envelope, data) {
  const res = JSON.stringify(Object.assign(envelope, data));
  return res;
}

function sendError(ws, name, error) {
  ws.send(
    formatMessage(
      { name, id },
      { data: error })
  );
}

function sendSuccess(ws, name, data) {
  ws.send(
    formatMessage(
      { name},
      { data }
    )
  );
}

function verifyToken(password, token) {
  if (!token) {
    return { valid: false, error: 'Security Token not provided' };
  } else {
    try {
      jwt.verify(token, password);
      return { valid: true, error: null };
    } catch (e) {
      return { valid: false, error: e };
    }
  }
}

function joiValidationErrorMsg(error) {
  if (error && error.details && error.details.length > 0) {
    return error.details[0].message;
  }
  return 'Vaidation Error';
}

function listenRunners(ws, msg) {
  db.find({})
    .then( runners => {
      runners.forEach( runner => {
        sendSuccess(ws, NEWRUNNER , runner)
      })
    })
    .catch(err => {
      sendError(ws, 'listen runners error', err);
    })

  const token = PubSub.subscribe(RUNNERUPDATE, runnerUpdate(ws));
  return token;
}

const runnerUpdate = _.curry( (ws, thisName, {name, msg}) => {
  sendSuccess(ws, name, msg);
})


app.ws.use(wsApi.routes()).use(wsApi.allowedMethods());
app.use(api.routes()).use(api.allowedMethods());

app.listen(5000);


function setTime(minute) {
  const startTime = (new Date((new Date) - minute * 60000)).getTime()
  db.find({})
    .then(runners => {
      const promises = runners.map ( runner => {
        const miles = runner.pace * minute;
        const lastMarkerDistance = miles - (miles % 1);

        const markerMinutes = minute - (runner.pace * (miles % 1) * 60);
        const lastMarkerTime = minute > -1 ? (new Date( startTime + markerMinutes * 60000)).getTime() : 0;
        const updatedRunner = Object.assign(runner, {lastMarkerDistance, lastMarkerTime});
        PubSub.publish(RUNNERUPDATE, {name: UPDATERUNNER, msg: updatedRunner});
        return db.update({_id: runner._id}, updatedRunner);
      });
      return Promise.all(promises);
    })
    .catch(err => {
      console.log(err);
    })

}

function replEval(cmd, context, filename, callback) {
  const args = cmd.trim().split(' ');
  const data = parse(args)
  if ('minute' in data) {
    setTime(data.minute);
    return callback(null);
  }
  else if (data._.indexOf('start') > -1) {
    setTime(0);
    return callback(null);
  }
  else if (data._.indexOf('reset') > -1) {
    setTime(-1);
    return callback(null);
  }
  else if (data._.indexOf('exit') > -1) {
    process.exit();
  }
  else {
    return callback(null, REPLHELP)
  }
}
console.log(REPLHELP);
repl.start({prompt: '> ', eval: replEval});
