import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/workflow/domain/entities/scheduler.dart';

/// Cron validation result for workflow scheduler jobs.
class WorkflowCronParseResult extends Equatable {
  const WorkflowCronParseResult({required this.isValid, this.reason});

  final bool isValid;
  final String? reason;

  @override
  List<Object?> get props => [isValid, reason];
}

/// Next run computation for a workflow scheduled job.
class WorkflowNextRunResult extends Equatable {
  const WorkflowNextRunResult({required this.nextRunAt, this.isDue = false});

  final DateTime nextRunAt;
  final bool isDue;

  @override
  List<Object?> get props => [nextRunAt, isDue];
}

/// Pure scheduling logic for workflow cron, recurring, delayed, and retry jobs.
/// Complements automation [SchedulerEngine] with workflow-domain records.
class WorkflowSchedulerEngine {
  WorkflowCronParseResult validateCron(String? expression) {
    if (expression == null || expression.trim().isEmpty) {
      return const WorkflowCronParseResult(isValid: false, reason: 'Cron expression is required');
    }
    final parts = expression.trim().split(RegExp(r'\s+'));
    if (parts.length < 5 || parts.length > 6) {
      return const WorkflowCronParseResult(isValid: false, reason: 'Cron must have 5 or 6 fields');
    }
    return const WorkflowCronParseResult(isValid: true);
  }

  WorkflowNextRunResult computeNextRun({
    required ScheduledJobRecord job,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).toUtc();
    return switch (job.scheduleType) {
      JobScheduleType.once => _nextOnce(job, current),
      JobScheduleType.delayed => _nextDelayed(job, current),
      JobScheduleType.recurring => _nextRecurring(job, current),
      JobScheduleType.cron => _nextCron(job, current),
    };
  }

  bool isDue({required ScheduledJobRecord job, DateTime? now}) {
    if (job.status == JobStatus.cancelled || job.status == JobStatus.completed) return false;
    final next = job.nextRunAt;
    if (next == null) return false;
    return !next.isAfter((now ?? DateTime.now()).toUtc());
  }

  List<ScheduledJobRecord> sortByPriority(List<ScheduledJobRecord> jobs, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toUtc();
    final scored = jobs.map((job) {
      var score = 0;
      if (isDue(job: job, now: current)) score += 1000;
      if (job.nextRunAt != null) {
        score += (current.difference(job.nextRunAt!).inSeconds).abs();
      }
      if (job.status == JobStatus.running) score -= 500;
      return (job: job, score: score);
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.job).toList();
  }

  ScheduledJobRecord markEnqueued(ScheduledJobRecord job, DateTime nextRunAt) => job.copyWith(
        status: JobStatus.queued,
        nextRunAt: nextRunAt,
      );

  ScheduledJobRecord markRunning(ScheduledJobRecord job, DateTime startedAt) => job.copyWith(
        status: JobStatus.running,
        lastRunAt: startedAt,
      );

  ScheduledJobRecord markCompleted(ScheduledJobRecord job, DateTime completedAt) {
    final next = computeNextRun(job: job, now: completedAt);
    final isRecurring = job.scheduleType == JobScheduleType.recurring || job.scheduleType == JobScheduleType.cron;
    return job.copyWith(
      status: isRecurring ? JobStatus.pending : JobStatus.completed,
      lastRunAt: completedAt,
      nextRunAt: isRecurring ? next.nextRunAt : null,
      retryCount: 0,
    );
  }

  ScheduledJobRecord markFailed(ScheduledJobRecord job, {bool retry = true}) {
    if (!retry || job.retryCount >= job.maxRetries) {
      return job.copyWith(status: JobStatus.failed, retryCount: job.retryCount + 1);
    }
    final delay = Duration(seconds: job.retryDelaySeconds * (job.retryCount + 1));
    return job.copyWith(
      status: JobStatus.pending,
      retryCount: job.retryCount + 1,
      nextRunAt: DateTime.now().toUtc().add(delay),
    );
  }

  SchedulerHealth evaluateHealth({
    required List<ScheduledJobRecord> jobs,
    required List<JobExecutionLog> recentLogs,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).toUtc();
    final due = jobs.where((j) => isDue(job: j, now: current)).length;
    final failed = jobs.where((j) => j.status == JobStatus.failed).length;
    final running = jobs.where((j) => j.status == JobStatus.running).length;
    final recentFailures = recentLogs.where((l) => !l.success).length;
    final isHealthy = failed == 0 && due < 50 && recentFailures < 10;
    return SchedulerHealth(
      isHealthy: isHealthy,
      dueJobCount: due,
      failedJobCount: failed,
      runningJobCount: running,
      recentFailureCount: recentFailures,
      checkedAt: current,
    );
  }

  WorkflowNextRunResult _nextOnce(ScheduledJobRecord job, DateTime now) {
    final runAt = job.runAt ?? now;
    return WorkflowNextRunResult(nextRunAt: runAt.toUtc(), isDue: !runAt.isAfter(now));
  }

  WorkflowNextRunResult _nextDelayed(ScheduledJobRecord job, DateTime now) {
    final delay = job.intervalSeconds ?? 0;
    final runAt = now.add(Duration(seconds: delay));
    return WorkflowNextRunResult(nextRunAt: runAt, isDue: delay <= 0);
  }

  WorkflowNextRunResult _nextRecurring(ScheduledJobRecord job, DateTime now) {
    final interval = job.intervalSeconds ?? 3600;
    final base = job.lastRunAt ?? now;
    var next = base.add(Duration(seconds: interval));
    while (next.isBefore(now)) {
      next = next.add(Duration(seconds: interval));
    }
    return WorkflowNextRunResult(nextRunAt: next, isDue: !next.isAfter(now));
  }

  WorkflowNextRunResult _nextCron(ScheduledJobRecord job, DateTime now) {
    final validation = validateCron(job.cronExpression);
    if (!validation.isValid) {
      return WorkflowNextRunResult(nextRunAt: now.add(const Duration(hours: 1)));
    }
    final parts = job.cronExpression!.trim().split(RegExp(r'\s+'));
    final minute = _parseCronField(parts[0], 0, 59, now.minute);
    final hour = _parseCronField(parts[1], 0, 23, now.hour);
    var next = DateTime.utc(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    if (job.lastRunAt != null && !next.isAfter(job.lastRunAt!)) {
      next = next.add(const Duration(days: 1));
    }
    return WorkflowNextRunResult(nextRunAt: next, isDue: !next.isAfter(now));
  }

  int _parseCronField(String field, int min, int max, int fallback) {
    if (field == '*') return fallback;
    final value = int.tryParse(field);
    if (value == null) return fallback;
    return value.clamp(min, max);
  }
}
