// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SnowboardRace {
    enum GameState { WaitingForPlayers, InProgress, Finished }

    struct Player {
        address addr;
        uint256 position;
        bool hasMoved;
    }

    struct Game {
        uint256 id;
        GameState state;
        address[] playerAddresses;
        mapping(address => Player) players;
        uint256 finishLine;
        address winner;
        uint256 turn;
    }

    uint256 public gameCounter;
    mapping(uint256 => Game) public games;

    event GameCreated(uint256 indexed gameId);
    event PlayerJoined(uint256 indexed gameId, address player);
    event PlayerMoved(uint256 indexed gameId, address player, uint256 roll, uint256 newPosition);
    event GameFinished(uint256 indexed gameId, address winner);

    modifier onlyInState(uint256 _gameId, GameState _state) {
        require(games[_gameId].state == _state, "Invalid game state");
        _;
    }

    function createGame(uint256 _finishLine) external returns (uint256) {
        require(_finishLine > 0, "Finish line must be greater than 0");

        gameCounter++;
        Game storage game = games[gameCounter];
        game.id = gameCounter;
        game.state = GameState.WaitingForPlayers;
        game.finishLine = _finishLine;

        emit GameCreated(gameCounter);
        return gameCounter;
    }

    function joinGame(uint256 _gameId) external onlyInState(_gameId, GameState.WaitingForPlayers) {
        Game storage game = games[_gameId];
        require(game.players[msg.sender].addr == address(0), "Already joined");
        require(game.playerAddresses.length < 4, "Game full");

        game.playerAddresses.push(msg.sender);
        game.players[msg.sender] = Player(msg.sender, 0, false);

        emit PlayerJoined(_gameId, msg.sender);

        if (game.playerAddresses.length >= 2) {
            game.state = GameState.InProgress;
        }
    }

    function move(uint256 _gameId, uint256 _randomRoll) external onlyInState(_gameId, GameState.InProgress) {
        require(_randomRoll >= 1 && _randomRoll <= 6, "Roll must be 1-6");

        Game storage game = games[_gameId];
        require(game.players[msg.sender].addr != address(0), "Not a player");
        require(!game.players[msg.sender].hasMoved, "Already moved this turn");

        game.players[msg.sender].position += _randomRoll;
        game.players[msg.sender].hasMoved = true;

        emit PlayerMoved(_gameId, msg.sender, _randomRoll, game.players[msg.sender].position);

        if (game.players[msg.sender].position >= game.finishLine) {
            game.state = GameState.Finished;
            game.winner = msg.sender;
            emit GameFinished(_gameId, msg.sender);
            return;
        }

        // Check if all players have moved, then reset for next turn
        bool allMoved = true;
        for (uint256 i = 0; i < game.playerAddresses.length; i++) {
            if (!game.players[game.playerAddresses[i]].hasMoved) {
                allMoved = false;
                break;
            }
        }

        if (allMoved) {
            for (uint256 i = 0; i < game.playerAddresses.length; i++) {
                game.players[game.playerAddresses[i]].hasMoved = false;
            }
            game.turn++;
        }
    }

    function getPlayerPosition(uint256 _gameId, address _player) external view returns (uint256) {
        return games[_gameId].players[_player].position;
    }

    function getPlayers(uint256 _gameId) external view returns (address[] memory) {
        return games[_gameId].playerAddresses;
    }

    function getWinner(uint256 _gameId) external view returns (address) {
        return games[_gameId].winner;
    }
}
