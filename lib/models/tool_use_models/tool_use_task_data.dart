/// Task Tool capability (READ / WRITE / EXECUTE).
enum TaskToolCapability {
  read,
  write,
  execute,
}

/// UI configuration for the Task Tool (enabled + capabilities).
class TaskToolUiConfig {
  final bool enabled;
  final List<TaskToolCapability> capabilities;

  const TaskToolUiConfig({
    this.enabled = true,
    this.capabilities = const [
      TaskToolCapability.read,
      TaskToolCapability.write,
    ],
  });

  /// Parameters saved in CREATE_TASK actor configuration (pattern like browser tool).
  TaskToolActorParameters toActorParameters() {
    return TaskToolActorParameters(
      read: capabilities.contains(TaskToolCapability.read),
      write: capabilities.contains(TaskToolCapability.write),
      execute: capabilities.contains(TaskToolCapability.execute),
    );
  }

  static TaskToolUiConfig fromActorParameters(TaskToolActorParameters p) {
    final caps = <TaskToolCapability>[];
    if (p.read) caps.add(TaskToolCapability.read);
    if (p.write) caps.add(TaskToolCapability.write);
    if (p.execute) caps.add(TaskToolCapability.execute);
    return TaskToolUiConfig(enabled: true, capabilities: caps);
  }
}

/// Config the FE saves inside CREATE_TASK native tool parameters.
class TaskToolActorParameters {
  final bool read;
  final bool write;
  final bool execute;

  const TaskToolActorParameters({
    this.read = true,
    this.write = true,
    this.execute = false,
  });
}

// --- Sub-tool input types (for LLM tool calls / parsing) ---

enum TaskScope { user, company }

enum TaskStatus { active, inactive }

enum TaskType { recurring, oneTime }

enum TaskTarget { agent, pipeline, marketplace }

class TaskListArgs {
  final TaskScope? scope;
  final TaskStatus? status;
  final TaskType? type;
  final TaskTarget? target;

  TaskListArgs({this.scope, this.status, this.type, this.target});
}

class TaskGetArgs {
  final String hashId;
  TaskGetArgs({required this.hashId});
}

class TaskExecutionListArgs {
  final String hashId;
  final int? take;
  final int? skip;
  final String? order; // 'ASC' | 'DESD'

  TaskExecutionListArgs({
    required this.hashId,
    this.take,
    this.skip,
    this.order,
  });
}

class TaskExecutionGetArgs {
  final String hashId;
  final String execHashId;
  TaskExecutionGetArgs({required this.hashId, required this.execHashId});
}

class TaskCreateArgs {
  final String? name;
  final TaskScope? scope;
  final TaskType type;
  final TaskTarget target;
  final int targetId;
  final String? cron;
  final String? executionDate;
  final String? timezone;
  final String? endsAt;
  final int? maxRetries;
  final bool? silentTask;
  final String? configurations;

  TaskCreateArgs({
    this.name,
    this.scope,
    required this.type,
    required this.target,
    required this.targetId,
    this.cron,
    this.executionDate,
    this.timezone,
    this.endsAt,
    this.maxRetries,
    this.silentTask,
    this.configurations,
  });
}

class TaskUpdateArgs {
  final String hashId;
  final String? name;
  final TaskStatus? status;
  final TaskType? type;
  final TaskTarget? target;
  final int? targetId;
  final String? cron;
  final String? executionDate;
  final String? timezone;
  final String? endsAt;
  final int? maxRetries;
  final bool? silentTask;
  final String? configurations;

  TaskUpdateArgs({
    required this.hashId,
    this.name,
    this.status,
    this.type,
    this.target,
    this.targetId,
    this.cron,
    this.executionDate,
    this.timezone,
    this.endsAt,
    this.maxRetries,
    this.silentTask,
    this.configurations,
  });
}

class TaskDeleteArgs {
  final String hashId;
  TaskDeleteArgs({required this.hashId});
}

class TaskRunNowArgs {
  final String hashId;
  TaskRunNowArgs({required this.hashId});
}

// --- Runtime response types ---

class ToolRuntimeResponse<T> {
  final String actorId;
  final String message;
  final List<T>? info;
  final List<String>? errors;
  final ToolRuntimeCost? cost;

  ToolRuntimeResponse({
    required this.actorId,
    required this.message,
    this.info,
    this.errors,
    this.cost,
  });

  factory ToolRuntimeResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    List<T>? infoList;
    if (json['info'] != null && fromJsonT != null) {
      infoList = (json['info'] as List)
          .map((e) => fromJsonT(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return ToolRuntimeResponse(
      actorId: json['actorId'] ?? '',
      message: json['message'] ?? '',
      info: infoList,
      errors: json['errors'] != null
          ? (json['errors'] as List).map((e) => e.toString()).toList()
          : null,
      cost: json['cost'] != null
          ? ToolRuntimeCost.fromJson(
              Map<String, dynamic>.from(json['cost'] as Map))
          : null,
    );
  }

  /// Primary display text: message + first error if present.
  String get displayMessage {
    if (errors != null && errors!.isNotEmpty) {
      return '$message ${errors!.first}';
    }
    return message;
  }
}

class ToolRuntimeCost {
  final int tokens;
  final int credits;

  ToolRuntimeCost({required this.tokens, required this.credits});

  factory ToolRuntimeCost.fromJson(Map<String, dynamic> json) {
    return ToolRuntimeCost(
      tokens: (json['tokens'] as num?)?.toInt() ?? 0,
      credits: (json['credits'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Task DTO from task_list / task_get.
class TaskDto {
  final int id;
  final String hashId;
  final String name;
  final int companyId;
  final String scope; // USER | COMPANY
  final String origin; // USER | PIPELINE | AGENT
  final int originId;
  final String target; // AGENT | PIPELINE | MARKETPLACE
  final int targetId;
  final String status; // ACTIVE | INACTIVE
  final bool silentTask;
  final String? cron;
  final String? timezone;
  final String? executionDate;
  final String? endsAt;
  final String type; // RECURRING | ONE_TIME
  final String? nextExecutionAt;
  final String? lastExecutionAt;
  final int? maxRetries;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  TaskDto({
    required this.id,
    required this.hashId,
    required this.name,
    required this.companyId,
    required this.scope,
    required this.origin,
    required this.originId,
    required this.target,
    required this.targetId,
    required this.status,
    required this.silentTask,
    this.cron,
    this.timezone,
    this.executionDate,
    this.endsAt,
    required this.type,
    this.nextExecutionAt,
    this.lastExecutionAt,
    this.maxRetries,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: (json['id'] as num).toInt(),
      hashId: json['hashId'] ?? '',
      name: json['name'] ?? '',
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      scope: json['scope'] ?? 'USER',
      origin: json['origin'] ?? 'USER',
      originId: (json['originId'] as num?)?.toInt() ?? 0,
      target: json['target'] ?? 'AGENT',
      targetId: (json['targetId'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? 'ACTIVE',
      silentTask: json['silentTask'] == true,
      cron: json['cron'],
      timezone: json['timezone'],
      executionDate: json['executionDate'],
      endsAt: json['endsAt'],
      type: json['type'] ?? 'ONE_TIME',
      nextExecutionAt: json['nextExecutionAt'],
      lastExecutionAt: json['lastExecutionAt'],
      maxRetries: (json['maxRetries'] as num?)?.toInt(),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      updatedBy: (json['updatedBy'] as num?)?.toInt(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

/// Task execution DTO (list item).
class TaskExecutionDto {
  final int id;
  final String execHashId;
  final int taskId;
  final String hashId;
  final String origin; // MANUAL | SCHEDULED
  final String status; // PENDING | QUEUED | EXECUTING | COMPLETED | ERROR | ARCHIVED
  final String? executionStart;
  final String? executionEnd;
  final bool error;
  final int errorCount;
  final bool read;
  final String? result;
  final int? creditsCost;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  TaskExecutionDto({
    required this.id,
    required this.execHashId,
    required this.taskId,
    required this.hashId,
    required this.origin,
    required this.status,
    this.executionStart,
    this.executionEnd,
    required this.error,
    required this.errorCount,
    required this.read,
    this.result,
    this.creditsCost,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskExecutionDto.fromJson(Map<String, dynamic> json) {
    return TaskExecutionDto(
      id: (json['id'] as num).toInt(),
      execHashId: json['execHashId'] ?? '',
      taskId: (json['taskId'] as num?)?.toInt() ?? 0,
      hashId: json['hashId'] ?? '',
      origin: json['origin'] ?? 'MANUAL',
      status: json['status'] ?? 'PENDING',
      executionStart: json['executionStart']?.toString(),
      executionEnd: json['executionEnd']?.toString(),
      error: json['error'] == true,
      errorCount: (json['errorCount'] as num?)?.toInt() ?? 0,
      read: json['read'] == true,
      result: json['result']?.toString(),
      creditsCost: (json['creditsCost'] as num?)?.toInt(),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      updatedBy: (json['updatedBy'] as num?)?.toInt(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

/// Task execution detail (task_execution_get).
class TaskExecutionDetailDto extends TaskExecutionDto {
  final dynamic input;
  final dynamic output;
  final List<dynamic>? errorDetails;

  TaskExecutionDetailDto({
    required super.id,
    required super.execHashId,
    required super.taskId,
    required super.hashId,
    required super.origin,
    required super.status,
    super.executionStart,
    super.executionEnd,
    required super.error,
    required super.errorCount,
    required super.read,
    super.result,
    super.creditsCost,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
    this.input,
    this.output,
    this.errorDetails,
  });

  factory TaskExecutionDetailDto.fromJson(Map<String, dynamic> json) {
    return TaskExecutionDetailDto(
      id: (json['id'] as num).toInt(),
      execHashId: json['execHashId'] ?? '',
      taskId: (json['taskId'] as num?)?.toInt() ?? 0,
      hashId: json['hashId'] ?? '',
      origin: json['origin'] ?? 'MANUAL',
      status: json['status'] ?? 'PENDING',
      executionStart: json['executionStart']?.toString(),
      executionEnd: json['executionEnd']?.toString(),
      error: json['error'] == true,
      errorCount: (json['errorCount'] as num?)?.toInt() ?? 0,
      read: json['read'] == true,
      result: json['result']?.toString(),
      creditsCost: (json['creditsCost'] as num?)?.toInt(),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      updatedBy: (json['updatedBy'] as num?)?.toInt(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      input: json['input'],
      output: json['output'],
      errorDetails: json['errorDetails'] != null
          ? (json['errorDetails'] as List).toList()
          : null,
    );
  }
}

/// Payload for task_execution_list (total + items for pagination).
class TaskExecutionListPayload {
  final int total;
  final List<TaskExecutionDto> items;

  TaskExecutionListPayload({required this.total, required this.items});

  factory TaskExecutionListPayload.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
        ?.map((e) =>
            TaskExecutionDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList() ?? [];
    return TaskExecutionListPayload(
      total: (json['total'] as num?)?.toInt() ?? items.length,
      items: items,
    );
  }
}

/// Parsed task tool message data for chat UI (info array + errors).
/// For task_create, also stores task args from toolArgs for display.
class ToolUseTaskData {
  final String message;
  final List<String>? errors;
  final List<Map<String, dynamic>>? info;

  /// Sub-tool name from SSE (e.g. task_create, task_list, task_update).
  final String? subToolName;
  /// Task name (create/update).
  final String? name;
  /// Task type: RECURRING | ONE_TIME.
  final String? taskType;
  /// Target: AGENT | PIPELINE | MARKETPLACE.
  final String? target;
  /// Cron expression (e.g. "0 0 1 * *").
  final String? cron;
  /// Timezone (e.g. "UTC").
  final String? timezone;
  /// Capabilities from tool call (for create_task display).
  final bool read;
  final bool write;
  final bool execute;

  ToolUseTaskData({
    required this.message,
    this.errors,
    this.info,
    this.subToolName,
    this.name,
    this.taskType,
    this.target,
    this.cron,
    this.timezone,
    this.read = false,
    this.write = false,
    this.execute = false,
  });

  String get displayMessage {
    if (errors != null && errors!.isNotEmpty) return '$message ${errors!.first}';
    return message;
  }

  bool get isCreateTask =>
      subToolName == 'task_create' || (name != null && cron != null);

  factory ToolUseTaskData.fromJson(Map<String, dynamic> json) {
    final infoRaw = json['info'];
    List<Map<String, dynamic>>? infoList;
    if (infoRaw is List) {
      infoList = infoRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    final errorsRaw = json['errors'];
    List<String>? errorsList;
    if (errorsRaw is List) {
      errorsList = errorsRaw.map((e) => e.toString()).toList();
    }
    // Capabilities from toolArgs (can be bool or string "true"/"false")
    bool readVal = false;
    if (json['read'] != null) {
      final v = json['read'];
      readVal = v == true || v == 'true';
    }
    bool writeVal = false;
    if (json['write'] != null) {
      final v = json['write'];
      writeVal = v == true || v == 'true';
    }
    bool executeVal = false;
    if (json['execute'] != null) {
      final v = json['execute'];
      executeVal = v == true || v == 'true';
    }
    return ToolUseTaskData(
      message: json['message']?.toString() ?? '',
      errors: errorsList,
      info: infoList,
      subToolName: json['subToolName']?.toString(),
      name: json['name']?.toString(),
      taskType: json['type']?.toString(),
      target: json['target']?.toString(),
      cron: json['cron']?.toString(),
      timezone: json['timezone']?.toString(),
      read: readVal,
      write: writeVal,
      execute: executeVal,
    );
  }
}
