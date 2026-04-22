import 'package:equatable/equatable.dart';

class ProjectUserAccessEntity extends Equatable {
  final int projectId;
  final int userId;

  const ProjectUserAccessEntity({
    required this.projectId,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        projectId,
        userId,
      ];
}
