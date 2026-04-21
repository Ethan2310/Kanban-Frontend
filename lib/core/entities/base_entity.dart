import 'package:equatable/equatable.dart';

/// Base class for all entities in the system to ensure
/// consistency across the data layer.
abstract class BaseEntity extends Equatable {
  final int id;
  final String guid;
  final int? createdById;
  final DateTime createdOn;
  final int? updatedById;
  final DateTime updatedOn;
  final bool isActive;

  const BaseEntity({
    required this.id,
    required this.guid,
    this.createdById,
    required this.createdOn,
    this.updatedById,
    required this.updatedOn,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        guid,
        createdById,
        createdOn,
        updatedById,
        updatedOn,
        isActive,
      ];
}

abstract class BasePaginatedEntity {
  final int totalCount;
  final int pageSize;
  final int currentPage;

  const BasePaginatedEntity({
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
  });

  List<Object?> get props => [
        totalCount,
        pageSize,
        currentPage,
      ];
}
