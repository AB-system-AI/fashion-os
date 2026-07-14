enum RuleStatus {
  draft,
  active,
  paused,
  archived;

  String get value => name;

  static RuleStatus fromValue(String? v) =>
      RuleStatus.values.firstWhere((e) => e.name == v, orElse: () => RuleStatus.draft);
}

enum WorkflowStatus {
  draft,
  active,
  paused,
  archived;

  String get value => name;

  static WorkflowStatus fromValue(String? v) =>
      WorkflowStatus.values.firstWhere((e) => e.name == v, orElse: () => WorkflowStatus.draft);
}

enum WorkflowStepType {
  action,
  condition,
  approval,
  delay,
  notification;

  String get value => name;

  static WorkflowStepType fromValue(String? v) =>
      WorkflowStepType.values.firstWhere((e) => e.name == v, orElse: () => WorkflowStepType.action);
}

enum JobScheduleType {
  once,
  recurring,
  cron,
  delayed;

  String get value => name;

  static JobScheduleType fromValue(String? v) =>
      JobScheduleType.values.firstWhere((e) => e.name == v, orElse: () => JobScheduleType.once);
}

enum JobStatus {
  pending,
  queued,
  running,
  completed,
  failed,
  cancelled;

  String get value => name;

  static JobStatus fromValue(String? v) =>
      JobStatus.values.firstWhere((e) => e.name == v, orElse: () => JobStatus.pending);
}

enum ExecutionStatus {
  pending,
  running,
  succeeded,
  failed,
  cancelled;

  String get value => name;

  static ExecutionStatus fromValue(String? v) =>
      ExecutionStatus.values.firstWhere((e) => e.name == v, orElse: () => ExecutionStatus.pending);
}

enum LogLevel {
  debug,
  info,
  warning,
  error;

  String get value => name;

  static LogLevel fromValue(String? v) =>
      LogLevel.values.firstWhere((e) => e.name == v, orElse: () => LogLevel.info);
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
  cancelled,
  expired;

  String get value => name;

  static ApprovalStatus fromValue(String? v) =>
      ApprovalStatus.values.firstWhere((e) => e.name == v, orElse: () => ApprovalStatus.pending);
}

enum TemplateType {
  email,
  sms,
  document,
  notification,
  report;

  String get value => name;

  static TemplateType fromValue(String? v) =>
      TemplateType.values.firstWhere((e) => e.name == v, orElse: () => TemplateType.document);
}

enum SuggestionType {
  rule,
  workflow,
  schedule,
  approval,
  optimization;

  String get value => name;

  static SuggestionType fromValue(String? v) =>
      SuggestionType.values.firstWhere((e) => e.name == v, orElse: () => SuggestionType.rule);
}

enum TriggerEventType {
  entityCreated,
  entityUpdated,
  entityDeleted,
  scheduleFired,
  manual,
  webhook;

  String get value => name;

  static TriggerEventType fromValue(String? v) =>
      TriggerEventType.values.firstWhere((e) => e.name == v, orElse: () => TriggerEventType.manual);
}
