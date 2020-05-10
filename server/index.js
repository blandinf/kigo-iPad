
var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);

let players = []
let deadPlayers = []

io.on('connection', (socket) => {
  console.log('a user is connected');

  socket.on('playerConnect', (msg) => {
    playerConnect(msg)
  })

  socket.on('playerIsDead', (msg) => {
    playerIsDead(msg)
  })

  socket.on('catchBonus', (msg) => {
      catchBonus(msg)
  })

  socket.on('disconnect', () => {
    console.log('user disconnected');
  });
});

http.listen(8080, () => {
  console.log('listening on *:8080');
});

function playerConnect (msg) {
    let player = JSON.parse(msg.player)    

    if (players.length < 2) {
        players.push(player)
        console.log("players", players)
    } 
    
    if (players.length == 2) {
        io.emit("GameIsReady")
    }
}

function playerIsDead (msg) {
    let player = JSON.parse(msg.player)
    deadPlayers.push(player)
    if (deadPlayers.length == 2) {
        console.log("send winner")
        io.emit("winnerIs", deadPlayers[1].id)
    }
}

function catchBonus (msg) {
    let player = JSON.parse(msg.player)
    let bonusType = msg.bonus
    let bonus = {
        playerIdToInflige: player.id,
        type: bonusType
    }
    io.emit("infligeBonus", JSON.stringify(bonus))
}