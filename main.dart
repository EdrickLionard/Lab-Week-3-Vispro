import 'dart:async';
import 'dart:io';

// ANSI escape codes untuk kontrol terminal
const String hideCursor = "\x1B[?25l";
const String showCursor = "\x1B[?25h";
const String resetColor = "\x1B[0m";

// Warna-warna ANSI untuk teks
const List<String> colors = [
  "\x1B[34m", // Biru
  "\x1B[35m", // Ungu
  "\x1B[38;5;185m", // Mint
];

// Fungsi untuk menggerakkan kursor ke posisi tertentu (row, col) di terminal
void moveCursor(int row, int col) {
  stdout.write("\x1B[${row + 1};${col + 1}H");
}

void main() {
  stdout.write("Masukkan namamu: ");
  String? nama = stdin.readLineSync() ?? '';

  // Ukuran terminal
  final width = stdout.terminalColumns;
  final height = stdout.terminalLines;
  final String chars = nama.isNotEmpty ? nama : "USER"; // Nama default

  // Pastikan animasi dimulai setelah baris pertama
  final startRow =
      1; // Memulai animasi dari baris ke-2 (row 1 dalam 0-based index)

  // Grid 2D untuk menyimpan karakter dan warna
  List<List<String>> grid =
      List.generate(height - startRow, (_) => List.filled(width, ' '));
  List<List<String>> gridColors =
      List.generate(height - startRow, (_) => List.filled(width, resetColor));

  int index = 0;
  int colorIndex = 0;
  bool isFilled = false; // Penanda apakah grid sudah penuh

  // Fungsi untuk mencetak grid ke terminal satu per satu huruf, menghindari flickering
  void printCharacter(int row, int col) {
    moveCursor(row + startRow,
        col); // Pindahkan kursor ke posisi (row + startRow, col)
    stdout.write("${gridColors[row][col]}${grid[row][col]}$resetColor");
  }

  // Fungsi animasi huruf berjalan
  Future<void> animate() async {
    stdout.write(hideCursor); // Sembunyikan kursor

    while (true) {
      int row = index ~/ width;
      int col = index % width;

      if (row < height - startRow) {
        // Update grid dengan huruf baru sesuai arah baris
        if (row % 2 == 0) {
          grid[row][col] = chars[index % chars.length]; // Kiri ke kanan
        } else {
          grid[row][width - 1 - col] =
              chars[index % chars.length]; // Kanan ke kiri
        }

        // Cetak huruf di posisi yang baru diubah
        printCharacter(row, col);

        index++;
        await Future.delayed(
            Duration(milliseconds: 50)); // Delay sebelum langkah berikutnya
      }

      // Ketika grid sudah penuh, mulai ubah warna satu per satu
      if (index >= width * (height - startRow)) {
        isFilled = true;
        index = 0; // Reset index untuk mengubah warna per huruf

        while (isFilled) {
          int row = index ~/ width;
          int col = index % width;

          // Update warna pada setiap huruf di grid
          gridColors[row][col] = colors[colorIndex % colors.length];

          // Cetak ulang huruf dengan warna baru
          printCharacter(row, col);

          index++;
          await Future.delayed(
              Duration(milliseconds: 50)); // Delay untuk transisi warna

          // Setelah semua karakter mendapat warna baru, mulai siklus baru
          if (index >= width * (height - startRow)) {
            colorIndex++; // Ubah ke warna berikutnya
            index = 0; // Reset indeks untuk siklus berikutnya
          }
        }
      }
    }
  }

  // Jalankan animasi
  animate();
}
