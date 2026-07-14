import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Immutable monetary value using minor units (e.g. cents) to avoid float errors.
class Money extends Equatable implements Comparable<Money> {
  const Money({required this.minorUnits, this.currencyCode = 'USD'});

  final int minorUnits;
  final String currencyCode;

  static const int scale = 100;

  factory Money.fromMajor(double amount, {String currencyCode = 'USD'}) {
    return Money(
      minorUnits: (amount * scale).round(),
      currencyCode: currencyCode,
    );
  }

  double get majorUnits => minorUnits / scale;

  bool get isNegative => minorUnits < 0;
  bool get isZero => minorUnits == 0;
  bool get isPositive => minorUnits > 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits: minorUnits + other.minorUnits, currencyCode: currencyCode);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits: minorUnits - other.minorUnits, currencyCode: currencyCode);
  }

  Money operator *(double multiplier) {
    return Money(
      minorUnits: (minorUnits * multiplier).round(),
      currencyCode: currencyCode,
    );
  }

  Money abs() => Money(minorUnits: minorUnits.abs(), currencyCode: currencyCode);

  Money round({RoundingMode mode = RoundingMode.halfUp}) {
    return this;
  }

  void _assertSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError('Currency mismatch: $currencyCode vs ${other.currencyCode}');
    }
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator >(Money other) => compareTo(other) > 0;
  bool operator <(Money other) => compareTo(other) < 0;
  bool operator >=(Money other) => compareTo(other) >= 0;
  bool operator <=(Money other) => compareTo(other) <= 0;

  @override
  List<Object?> get props => [minorUnits, currencyCode];
}

/// Percentage value object (0–100 scale).
class Percentage extends Equatable {
  const Percentage(this.value);

  final double value;

  bool get isValid => value >= 0 && value <= 100;

  double applyTo(double amount) => amount * (value / 100);

  Money applyToMoney(Money amount) => amount * (value / 100);

  @override
  List<Object?> get props => [value];
}

/// Quantity value object for inventory and sales lines.
class Quantity extends Equatable implements Comparable<Quantity> {
  const Quantity(this.value);

  final double value;

  bool get isPositive => value > 0;
  bool get isZero => value == 0;
  bool get isNegative => value < 0;

  Quantity operator +(Quantity other) => Quantity(value + other.value);
  Quantity operator -(Quantity other) => Quantity(value - other.value);

  @override
  int compareTo(Quantity other) => value.compareTo(other.value);

  @override
  List<Object?> get props => [value];
}
