import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';

class CronParseResult {
  const CronParseResult({required this.isValid, this.reason});

  final bool isValid;
  final String? reason;
}

class NextRunResult {
  const NextRunResult({required this.nextRunAt, this.isDue = false});

  final DateTime nextRunAt;
  final bool isDue;
}

class QueuePriorityResult {
  const QueuePriorityResult({
    required this.item,
    required this.score,
  });

  final ScheduledJob item;
  final int score;
}

/// Pure scheduling logic for cron, recurring, delayed, and one-shot jobs.
class SchedulerEngine {
  CronParseResult validateCron(String? expression) {
    if (expression == null || expression.trim().isEmpty) {
      return const CronParseResult(isValid: false, reason: 'Cron expression is required');
    }
    final parts = expression.trim().split(RegExp(r'\s+'));
    if (parts.length < 5 || parts.length > 6) {
      return const CronParseResult(isValid: false, reason: 'Cron must have 5 or 6 fields');
    }
    return const CronParseResult(isValid: true);
  }

  NextRunResult computeNextRun({
    required ScheduleSpec spec,
    DateTime? lastRunAt,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).toUtc();
    return switch (spec.scheduleType) {
      JobScheduleType.once => _nextOnce(spec, current),
      JobScheduleType.delayed => _nextDelayed(spec, current),
      JobScheduleType.recurring => _nextRecurring(spec, lastRunAt, current),
      JobScheduleType.cron => _nextCron(spec, lastRunAt, current),
    };
  }

  bool isDue({
    required ScheduledJob job,
    DateTime? now,
  }) {
    if (job.status == JobStatus.cancelled || job.status == JobStatus.completed) return false;
    final next = job.nextRunAt;
    if (next == null) return false;
    return !next.isAfter((now ?? DateTime.now()).toUtc());
  }

  List<ScheduledJob> sortByPriority(List<ScheduledJob> jobs, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toUtc();
    final scored = jobs.map((job) {
      var score = 0;
      if (isDue(job: job, now: current)) score += 1000;
      if (job.nextRunAt != null) {
        score += (current.difference(job.nextRunAt!).inSeconds).abs();
      }
      if (job.status == JobStatus.running) score -= 500;
      return QueuePriorityResult(item: job, score: score);
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.item).toList();
  }

  ScheduledJob markEnqueued(ScheduledJob job, DateTime nextRunAt) => job.copyWith(
        status: JobStatus.queued,
        nextRunAt: nextRunAt,
      );

  ScheduledJob markRunning(ScheduledJob job, DateTime startedAt) => job.copyWith(
        status: JobStatus.running,
        lastRunAt: startedAt,
      );

  ScheduledJob markCompleted(ScheduledJob job, ScheduleSpec spec, DateTime completedAt) {
    final next = computeNextRun(spec: spec, lastRunAt: completedAt, now: completedAt);
    final isRecurring = spec.scheduleType == JobScheduleType.recurring || spec.scheduleType == JobScheduleType.cron;
    return job.copyWith(
      status: isRecurring ? JobStatus.pending : JobStatus.completed,
      lastRunAt: completedAt,
      nextRunAt: isRecurring ? next.nextRunAt : null,
    );
  }

  ScheduledJob markFailed(ScheduledJob job, {bool retry = true}) => job.copyWith(
        status: retry ? JobStatus.pending : JobStatus.failed,
      );

  NextRunResult _nextOnce(ScheduleSpec spec, DateTime now) {
    final runAt = spec.runAt ?? now;
    return NextRunResult(nextRunAt: runAt.toUtc(), isDue: !runAt.isAfter(now));
  }

  NextRunResult _nextDelayed(ScheduleSpec spec, DateTime now) {
    final delay = spec.intervalSeconds ?? 0;
    final runAt = now.add(Duration(seconds: delay));
    return NextRunResult(nextRunAt: runAt, isDue: delay <= 0);
  }

  NextRunResult _nextRecurring(ScheduleSpec spec, DateTime? lastRunAt, DateTime now) {
    final interval = spec.intervalSeconds ?? 3600;
    final base = lastRunAt ?? now;
    var next = base.add(Duration(seconds: interval));
    while (next.isBefore(now)) {
      next = next.add(Duration(seconds: interval));
    }
    return NextRunResult(nextRunAt: next, isDue: !next.isAfter(now));
  }

  NextRunResult _nextCron(ScheduleSpec spec, DateTime? lastRunAt, DateTime now) {
    final validation = validateCron(spec.cronExpression);
    if (!validation.isValid) {
      return NextRunResult(nextRunAt: now.add(const Duration(hours: 1)));
    }
    final parts = spec.cronExpression!.trim().split(RegExp(r'\s+'));
    final minute = _parseCronField(parts[0], 0, 59, now.minute);
    final hour = _parseCronField(parts[1], 0, 23, now.hour);
    var next = DateTime.utc(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    if (lastRunAt != null && !next.isAfter(lastRunAt)) {
      next = next.add(const Duration(days: 1));
    }
    return NextRunResult(nextRunAt: next, isDue: !next.isAfter(now));
  }

  int _parseCronField(String field, int min, int max, int fallback) {
    if (field == '*') return fallback;
    final value = int.tryParse(field);
    if (value == null) return fallback;
    return value.clamp(min, max);
  }
}
