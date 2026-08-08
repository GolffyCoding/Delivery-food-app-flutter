extension StringExtensions on String {
  String get capitalized => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalized).join(' ');

  String get snakeToTitle => split('_').map((w) => w.capitalized).join(' ');

  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPhone => RegExp(r'^\+?[0-9]{10,15}$').hasMatch(this);

  String get currencyFormat {
    final num = double.tryParse(replaceAll(RegExp(r'[^\d.]'), ''));
    if (num == null) return this;
    return '\$${num.toStringAsFixed(2)}';
  }

  String get numericOnly => replaceAll(RegExp(r'[^0-9]'), '');
}
