/// Contract for persistence. A future cloud-sync layer can implement this
/// interface while keeping the same screens and calculation logic.
abstract interface class HabitRepository {
  Future<Map<String, dynamic>?> read();
  Future<void> write(Map<String, dynamic> state);
}
