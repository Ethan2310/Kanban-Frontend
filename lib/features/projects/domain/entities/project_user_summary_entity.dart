import 'package:equatable/equatable.dart';
import 'package:kanban_frontend/core/entities/base_entity.dart';

class ProjectUserSummaryEntity extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  const ProjectUserSummaryEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, email];
}

class ProjectUserListEntity extends BasePaginatedEntity {
  final List<ProjectUserSummaryEntity> users;

  const ProjectUserListEntity({
    required this.users,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        users,
      ];
}
