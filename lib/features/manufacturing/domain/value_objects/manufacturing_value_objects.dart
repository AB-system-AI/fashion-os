import 'package:equatable/equatable.dart';

class ProductionQuantity extends Equatable {
  const ProductionQuantity({required this.planned, required this.completed, required this.scrapped});

  final double planned;
  final double completed;
  final double scrapped;

  double get remaining => (planned - completed - scrapped).clamp(0, double.infinity);
  double get yieldPercent => planned > 0 ? (completed / planned) * 100 : 0;

  @override
  List<Object?> get props => [planned, completed, scrapped];
}

class OperationDuration extends Equatable {
  const OperationDuration({required this.setupMinutes, required this.runMinutesPerUnit});

  final int setupMinutes;
  final double runMinutesPerUnit;

  double totalMinutes(double quantity) => setupMinutes + (runMinutesPerUnit * quantity);

  @override
  List<Object?> get props => [setupMinutes, runMinutesPerUnit];
}

class CapacityHours extends Equatable {
  const CapacityHours({required this.available, required this.scheduled, required this.utilized});

  final double available;
  final double scheduled;
  final double utilized;

  double get remaining => (available - scheduled).clamp(0, double.infinity);
  double get utilizationPercent => available > 0 ? (utilized / available) * 100 : 0;

  @override
  List<Object?> get props => [available, scheduled, utilized];
}

class YieldRate extends Equatable {
  const YieldRate({required this.inputQty, required this.outputQty});

  final double inputQty;
  final double outputQty;

  double get rate => inputQty > 0 ? outputQty / inputQty : 0;

  @override
  List<Object?> get props => [inputQty, outputQty];
}

class ScrapRate extends Equatable {
  const ScrapRate({required this.produced, required this.scrapped});

  final double produced;
  final double scrapped;

  double get rate => produced > 0 ? scrapped / produced : 0;

  @override
  List<Object?> get props => [produced, scrapped];
}
