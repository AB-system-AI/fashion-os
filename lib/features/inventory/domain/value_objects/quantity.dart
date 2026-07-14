import 'package:equatable/equatable.dart';

/// Non-negative stock quantity with safe arithmetic.
class Quantity extends Equatable {
  const Quantity(this.value);

  final double value;

  static const zero = Quantity(0);

  factory Quantity.parse(Object? raw) {
    if (raw is num) return Quantity(raw.toDouble());
    return Quantity(double.tryParse(raw?.toString() ?? '') ?? 0);
  }

  bool get isZero => value == 0;
  bool get isPositive => value > 0;
  bool get isNegative => value < 0;

  Quantity operator +(Quantity other) => Quantity(value + other.value);
  Quantity operator -(Quantity other) => Quantity(value - other.value);

  bool operator >=(Quantity other) => value >= other.value;
  bool operator <=(Quantity other) => value <= other.value;

  @override
  List<Object?> get props => [value];
}
