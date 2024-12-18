import 'dart:math';
import 'dart:io';

const int rows = 6;
const int cols = 10;
const int mines = 8;

// Generar el tablero inicial
List<List<String>> generarTablero() {
  return List.generate(rows, (_) => List.generate(cols, (_) => '·'));
}

// Generar el tablero con minas
List<List<bool>> generarMines() {
  var tableroMines =
      List.generate(rows, (_) => List.generate(cols, (_) => false));
  var rng = Random();

  // Colocar al menos 2 minas en cada cuadrante
  for (int i = 0; i < mines;) {
    int x = rng.nextInt(rows);
    int y = rng.nextInt(cols);

    bool cuadranteValido = ((x < rows ~/ 2 && y < cols ~/ 2) ||
        (x < rows ~/ 2 && y >= cols ~/ 2) ||
        (x >= rows ~/ 2 && y < cols ~/ 2) ||
        (x >= rows ~/ 2 && y >= cols ~/ 2));

    if (!tableroMines[x][y] &&
        cuadranteValido &&
        cuadranteMina(tableroMines, x, y)) {
      tableroMines[x][y] = true;
      i++;
    }
  }

  return tableroMines;
}

// Verifica si se cumplen las restricciones de 2 minas por cuadrante
bool cuadranteMina(List<List<bool>> tablero, int x, int y) {
  int cuadranteMinas = 0;
  int startRow = x < rows ~/ 2 ? 0 : rows ~/ 2;
  int startCol = y < cols ~/ 2 ? 0 : cols ~/ 2;

  for (int i = startRow; i < startRow + rows ~/ 2; i++) {
    for (int j = startCol; j < startCol + cols ~/ 2; j++) {
      if (tablero[i][j]) cuadranteMinas++;
    }
  }

  return cuadranteMinas < 2;
}

// Contar minas adyacentes
int contarMinasAdyacentes(List<List<bool>> tableroMines, int x, int y) {
  int count = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      int nx = x + dx, ny = y + dy;
      if (nx >= 0 &&
          nx < rows &&
          ny >= 0 &&
          ny < cols &&
          tableroMines[nx][ny]) {
        count++;
      }
    }
  }
  return count;
}

// Mover una mina a otra posición válida
void moverMina(List<List<bool>> tableroMines, int x, int y) {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (!tableroMines[i][j] && (i != x || j != y)) {
        tableroMines[i][j] = true;
        tableroMines[x][y] = false;
        return;
      }
    }
  }
}

// Destapar casillas recursivamente
bool destaparCasilla(List<List<String>> tablero, List<List<bool>> tableroMines,
    int x, int y, bool esPrimeraJugada, bool esJugadaUsuario) {
  if (x < 0 || x >= rows || y < 0 || y >= cols || tablero[x][y] != '·') {
    return false;
  }

  if (tableroMines[x][y]) {
    if (esPrimeraJugada) {
      moverMina(tableroMines, x, y);
    } else if (esJugadaUsuario) {
      return true;
    } else {
      return false;
    }
  }

  // Contar minas adyacentes
  int numMinas = contarMinasAdyacentes(tableroMines, x, y);

  // Si no tiene minas adyacentes, mostrar un espacio vacío
  if (numMinas == 0) {
    tablero[x][y] = ' ';
  } else {
    tablero[x][y] = numMinas.toString();
  }

  // Si la casilla no tiene minas adyacentes y no tiene ninguna mina tocando,
  // mostramos las casillas vecinas
  if (numMinas == 0) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (!(dx == 0 && dy == 0)) {
          destaparCasilla(tablero, tableroMines, x + dx, y + dy, false, false);
        }
      }
    }
  }

  return false;
}

// Mostrar tablero con minas y casillas descubiertas
void mostrarTableroConMinas(
    List<List<String>> tablero, List<List<bool>> tableroMines) {
  print(' 0123456789');
  for (int i = 0; i < rows; i++) {
    stdout.write(String.fromCharCode(65 + i)); // Mostrar la letra de la fila
    for (int j = 0; j < cols; j++) {
      if (tableroMines[i][j]) {
        stdout.write('*');
      } else if (tablero[i][j] == '·' || tablero[i][j] == '#') {
        stdout.write(
            tablero[i][j]); // Mostrar casillas no destapadas o con bandera
      } else {
        stdout.write(tablero[i][j]); // Mostrar casillas destapadas
      }
    }
    print('');
  }
}

// Mostrar tablero solo con casillas descubiertas
void mostrarTablero(List<List<String>> tablero) {
  print(' 0123456789');
  for (int i = 0; i < rows; i++) {
    stdout.write(String.fromCharCode(65 + i)); // Mostrar la letra de la fila
    print(tablero[i].join()); // Mostrar la fila del tablero
  }
}

void main() {
  var tablero = generarTablero();
  var tableroMines = generarMines();
  int tiradas = 0;
  bool jugando = true;

  while (jugando) {
    mostrarTablero(tablero);
    stdout.write('Escriu una comanda: ');
    String? comando = stdin.readLineSync()?.toUpperCase();

    if (comando == null || comando.isEmpty) {
      print('Comanda no válida. Intenta de nuevo.');
      continue;
    }

    if (comando == 'TRAMPES' || comando == 'CHEAT') {
      mostrarTableroConMinas(tablero, tableroMines);
      continue;
    }

    if (comando == 'AJUDA' || comando == 'HELP') {
      print(
          'Comandes disponibles: \n- Escollir casella: (ex: A1)\n- Posar bandera: (ex: A1 FLAG)\n- Mostrar trucs: TRAMPES o CHEAT');
      continue;
    }

    if (comando.endsWith(' FLAG') || comando.endsWith(' BANDERA')) {
      try {
        int x = comando.codeUnitAt(0) - 65;
        int y = int.parse(comando.substring(1, comando.length - 5));
        if (x < 0 || x >= rows || y < 0 || y >= cols) {
          print('Posició fora de límits. Intenta de nou.');
          continue;
        }
        tablero[x][y] = tablero[x][y] == '#' ? '·' : '#';
      } catch (e) {
        print('Comanda no válida. Usa el formato correcto: (ex: A1 FLAG)');
      }
      continue;
    }

    try {
      int x = comando.codeUnitAt(0) - 65;
      int y = int.parse(comando.substring(1));
      if (x < 0 || x >= rows || y < 0 || y >= cols) {
        print('Posició fora de límits. Intenta de nou.');
        continue;
      }

      if (destaparCasilla(tablero, tableroMines, x, y, tiradas == 0, true)) {
        print('Has perdut!');
        mostrarTablero(tableroMines
            .map((fila) => fila.map((c) => c ? '*' : '·').toList())
            .toList());
        jugando = false;
      } else {
        tiradas++;
      }

      if (tablero.expand((f) => f).where((c) => c == '·').isEmpty) {
        print('Has guanyat!');
        jugando = false;
      }
    } catch (e) {
      print('Comanda no válida. Usa el formato correcto: (ex: A1)');
    }
  }

  print('Número de tirades: $tiradas');
}
