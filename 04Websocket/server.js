const WebSocketServer = require('ws').Server;
const Rx = require('rx');
const dateFormat = require('dateformat');

const server = new WebSocketServer({ port: 5000 });

server.on('connection', function connection(ws) {
  console.log('client connected!')
  const pauser = new Rx.Subject();
  Rx.Observable
    .interval( 1000 )
    .timeInterval()
    .map( x => new Date)
    .map( now => dateFormat(now, "h:MM:ss TT") )
    .pausable( pauser )
    .subscribe( ( time ) => {
        if (ws.readyState === ws.OPEN){
          ws.send(JSON.stringify({time}));
        }
        else if (ws.readyState === ws.CLOSED) {
          pauser.onNext(false);
        }
      }
    );
  ws.on('message', ( message ) => {
    if ( message === "start" ){
      pauser.onNext(true);
    }
    else if ( message === "stop" ) {
      pauser.onNext(false); 
    }
  });
  ws.on('close', ( ) => {
    console.log('client disconnected!');
  })

});