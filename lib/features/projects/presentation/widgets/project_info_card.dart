import 'package:flutter/material.dart';
import 'package:kanban_frontend/core/ui/widgets/icon_button.dart';
import 'package:kanban_frontend/core/ui/widgets/info_card.dart';
import 'package:kanban_frontend/core/ui/widgets/info_table.dart';

class ProjectAdminUser {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  const ProjectAdminUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}

class ProjectInfoCard extends StatelessWidget {
  final String projectName;
  final String projectDescription;
  final List<ProjectAdminUser> admins;
  final VoidCallback onAddAdmin;
  final VoidCallback onDeleteProject;
  final VoidCallback onUpdateProject;
  final ValueChanged<ProjectAdminUser> onRemoveAdmin;
  final double adminTableWidth;
  final double adminTableHeight;
  final TextStyle? adminHeadingTextStyle;
  final TextStyle? adminDataTextStyle;
  final bool isAdmin;

  const ProjectInfoCard({
    super.key,
    required this.projectName,
    required this.projectDescription,
    required this.admins,
    required this.onAddAdmin,
    required this.onDeleteProject,
    required this.onUpdateProject,
    required this.onRemoveAdmin,
    this.adminTableWidth = 900,
    this.adminTableHeight = 220,
    this.adminHeadingTextStyle,
    this.adminDataTextStyle,
    this.isAdmin = true,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Project',
      sections: [
        InfoCardSection(
          title: 'Heading',
          child: Text(
            'Project : $projectName',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        InfoCardSection(
          title: 'Information',
          child: Text('Description : $projectDescription'),
        ),
        if (isAdmin)
          InfoCardSection(
            title: 'AdminData',
            child: _buildAdminData(context),
          ),
        if (isAdmin)
          InfoCardSection(
            title: 'Actions',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  onPressed: onDeleteProject,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete project',
                ),
                IconedButton(
                  onPressed: onUpdateProject,
                  text: 'Update Project',
                  size: const Size(220, 52),
                  icon: Icons.edit,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAdminData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoTable<ProjectAdminUser>(
          width: adminTableWidth,
          height: adminTableHeight,
          headingTextStyle: adminHeadingTextStyle,
          dataTextStyle: adminDataTextStyle,
          emptyText: 'No users added',
          rows: admins,
          columns: [
            InfoTableColumn<ProjectAdminUser>(
              heading: 'First Name',
              flex: 2,
              textValue: (row) => row.firstName,
            ),
            InfoTableColumn<ProjectAdminUser>(
              heading: 'Last Name',
              flex: 2,
              textValue: (row) => row.lastName,
            ),
            InfoTableColumn<ProjectAdminUser>(
              heading: 'Email',
              flex: 3,
              textValue: (row) => row.email,
            ),
            InfoTableColumn<ProjectAdminUser>(
              heading: '',
              flex: 2,
              headingTextAlign: TextAlign.right,
              cellBuilder: (context, row) => Align(
                alignment: Alignment.centerRight,
                child: IconedButton(
                  onPressed: () => onRemoveAdmin(row),
                  backgroundColor: Colors.red,
                  size: const Size(52, 40),
                  minimumSize: const Size(40, 36),
                  maximumSize: const Size(80, 42),
                  icon: Icons.remove,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: IconedButton(
            onPressed: onAddAdmin,
            text: 'Add User',
            size: const Size(190, 50),
            icon: Icons.person_add,
          ),
        ),
      ],
    );
  }
}
