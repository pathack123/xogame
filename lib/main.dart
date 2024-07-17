import 'package:flutter/material.dart';
import 'package:xogame_nipat_sangsima/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: TicTacToePage(),
    );
  }
}

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  List<String> board = List.generate(9, (index) => '');
  String currentPlayer = 'X';
  bool gameOver = false;
  String winner = '';

  void resetBoard() {
    setState(() {
      board = List.generate(9, (index) => '');
      currentPlayer = 'X';
      gameOver = false;
      winner = '';
    });
  }

  void makeMove(int index) {
    if (board[index] == '' && !gameOver) {
      setState(() {
        board[index] = currentPlayer;
        if (checkWinner(currentPlayer)) {
          gameOver = true;
          winner = currentPlayer;
          DatabaseHelper.instance.insertGame(winner);
        } else if (!board.contains('')) {
          gameOver = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  bool checkWinner(String player) {
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var condition in winConditions) {
      if (condition.every((index) => board[index] == player)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Column(
            children: [
              Text(
                'กฎคือ X คือ คนที่จะได้กดคนแรก',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16.0,
                ),
              ),
              Text(
                '             O คือ คนที่จะได้กดคนถัดไป',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
        title: const Text(
          'X ❤️ O by Nipat Sangsima ➕ ChatGpt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => makeMove(index),
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      board[index],
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          gameOver
              ? Column(
                  children: [
                    Text(
                      winner.isEmpty ? "It's a Draw!" : '$winner คือผู้ชนะ🏆',
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: resetBoard,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal, // Text color
                        shadowColor: Colors.tealAccent, // Shadow color
                        elevation: 5, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15), // Padding
                      ),
                      child: const Text('เล่นอีกครั้ง'),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.fetchGames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var games = snapshot.data!;
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('เกมที่ ${games[index]['id']}'),
                subtitle: Text('ผู้ชนะ: ${games[index]['winner']}'),
              );
            },
          );
        },
      ),
    );
  }
}
