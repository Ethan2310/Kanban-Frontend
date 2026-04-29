import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';

class BoardModel extends BoardEntity {
  const BoardModel({
    required super.id,
    required super.name,
    super.description,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: (json['id'] ?? json['boardId']) as int,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boardId': id,
      'name': name,
      'description': description,
    };
  }
}

class BoardListModel extends BoardListEntity {
  const BoardListModel({
    required super.boards,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });

  factory BoardListModel.fromJson(Map<String, dynamic> json) {
    final pagination =
        (json['pagination'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return BoardListModel(
      boards: ((json['boards'] as List?) ?? <dynamic>[])
          .map((e) => BoardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (pagination['totalCount'] as int?) ?? 0,
      pageSize: (pagination['pageSize'] as int?) ?? 0,
      pageNumber: (pagination['pageNumber'] as int?) ?? 1,
      totalPages: (pagination['totalPages'] as int?) ?? 1,
    );
  }
}
