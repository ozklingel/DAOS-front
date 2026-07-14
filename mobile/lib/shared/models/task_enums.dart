enum TaskStatus {
  open,
  completed,
  snoozed,
  dismissed,
  overdue;

  String get label {
    switch (this) {
      case TaskStatus.open:
        return 'Open';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.snoozed:
        return 'Snoozed';
      case TaskStatus.dismissed:
        return 'Dismissed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }
}

enum TaskPriority {
  critical,
  high,
  medium,
  low,
  none;

  String get label {
    switch (this) {
      case TaskPriority.critical:
        return 'Critical';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.none:
        return 'None';
    }
  }
}

enum TaskSortField {
  deadline,
  createdAt,
  priorityScore;

  String get apiValue {
    switch (this) {
      case TaskSortField.deadline:
        return 'deadline';
      case TaskSortField.createdAt:
        return 'created_at';
      case TaskSortField.priorityScore:
        return 'priority_score';
    }
  }

  String get label {
    switch (this) {
      case TaskSortField.deadline:
        return 'Deadline';
      case TaskSortField.createdAt:
        return 'Creation Date';
      case TaskSortField.priorityScore:
        return 'Priority Score';
    }
  }
}

enum TaskAction {
  complete,
  snooze,
  dismiss;

  String get apiValue => name;
}
