/// Workflow module status values.
enum WorkflowDefinitionStatus {
  draft('draft'),
  active('active'),
  archived('archived');

  const WorkflowDefinitionStatus(this.value);
  final String value;

  static WorkflowDefinitionStatus fromValue(String? v) =>
      WorkflowDefinitionStatus.values.firstWhere((e) => e.value == v, orElse: () => WorkflowDefinitionStatus.draft);
}

enum WorkflowInstanceStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  rejected('rejected'),
  cancelled('cancelled');

  const WorkflowInstanceStatus(this.value);
  final String value;

  static WorkflowInstanceStatus fromValue(String? v) =>
      WorkflowInstanceStatus.values.firstWhere((e) => e.value == v, orElse: () => WorkflowInstanceStatus.pending);
}

enum ApprovalRequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  delegated('delegated'),
  escalated('escalated'),
  expired('expired');

  const ApprovalRequestStatus(this.value);
  final String value;

  static ApprovalRequestStatus fromValue(String? v) =>
      ApprovalRequestStatus.values.firstWhere((e) => e.value == v, orElse: () => ApprovalRequestStatus.pending);
}

enum NotificationItemStatus {
  unread('unread'),
  read('read'),
  archived('archived');

  const NotificationItemStatus(this.value);
  final String value;

  static NotificationItemStatus fromValue(String? v) =>
      NotificationItemStatus.values.firstWhere((e) => e.value == v, orElse: () => NotificationItemStatus.unread);
}

enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromValue(String? v) =>
      NotificationPriority.values.firstWhere((e) => e.value == v, orElse: () => NotificationPriority.normal);
}

enum ReminderScheduleType {
  once('once'),
  interval('interval'),
  cron('cron');

  const ReminderScheduleType(this.value);
  final String value;

  static ReminderScheduleType fromValue(String? v) =>
      ReminderScheduleType.values.firstWhere((e) => e.value == v, orElse: () => ReminderScheduleType.once);
}

enum EscalationTriggerType {
  timeout('timeout'),
  noResponse('no_response'),
  threshold('threshold');

  const EscalationTriggerType(this.value);
  final String value;

  static EscalationTriggerType fromValue(String? v) =>
      EscalationTriggerType.values.firstWhere((e) => e.value == v, orElse: () => EscalationTriggerType.timeout);
}

enum WorkflowVersionStatus {
  draft('draft'),
  published('published'),
  archived('archived');

  const WorkflowVersionStatus(this.value);
  final String value;

  static WorkflowVersionStatus fromValue(String? v) =>
      WorkflowVersionStatus.values.firstWhere((e) => e.value == v, orElse: () => WorkflowVersionStatus.draft);
}

enum WorkflowActionType {
  approval('approval'),
  notification('notification'),
  delay('delay'),
  webhook('webhook'),
  script('script');

  const WorkflowActionType(this.value);
  final String value;

  static WorkflowActionType fromValue(String? v) =>
      WorkflowActionType.values.firstWhere((e) => e.value == v, orElse: () => WorkflowActionType.approval);
}

enum ConditionOperator {
  equals('eq'),
  notEquals('neq'),
  greaterThan('gt'),
  lessThan('lt'),
  contains('contains'),
  exists('exists');

  const ConditionOperator(this.value);
  final String value;

  static ConditionOperator fromValue(String? v) =>
      ConditionOperator.values.firstWhere((e) => e.value == v, orElse: () => ConditionOperator.equals);
}

enum WorkflowExecutionStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const WorkflowExecutionStatus(this.value);
  final String value;

  static WorkflowExecutionStatus fromValue(String? v) =>
      WorkflowExecutionStatus.values.firstWhere((e) => e.value == v, orElse: () => WorkflowExecutionStatus.pending);
}

enum JobScheduleType {
  once('once'),
  delayed('delayed'),
  recurring('recurring'),
  cron('cron');

  const JobScheduleType(this.value);
  final String value;

  static JobScheduleType fromValue(String? v) =>
      JobScheduleType.values.firstWhere((e) => e.value == v, orElse: () => JobScheduleType.once);
}

enum JobStatus {
  pending('pending'),
  queued('queued'),
  running('running'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const JobStatus(this.value);
  final String value;

  static JobStatus fromValue(String? v) =>
      JobStatus.values.firstWhere((e) => e.value == v, orElse: () => JobStatus.pending);
}

enum NotificationQueueStatus {
  pending('pending'),
  processing('processing'),
  sent('sent'),
  failed('failed'),
  deadLetter('dead_letter');

  const NotificationQueueStatus(this.value);
  final String value;

  static NotificationQueueStatus fromValue(String? v) =>
      NotificationQueueStatus.values.firstWhere((e) => e.value == v, orElse: () => NotificationQueueStatus.pending);
}

enum ApprovalPatternType {
  sequential('sequential'),
  parallel('parallel'),
  conditional('conditional'),
  percentage('percentage'),
  department('department'),
  role('role'),
  user('user'),
  amount('amount');

  const ApprovalPatternType(this.value);
  final String value;

  static ApprovalPatternType fromValue(String? v) =>
      ApprovalPatternType.values.firstWhere((e) => e.value == v, orElse: () => ApprovalPatternType.sequential);
}
