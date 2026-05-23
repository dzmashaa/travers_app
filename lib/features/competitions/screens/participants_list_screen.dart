import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/repositories/participant_repository.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/widgets/app_search_field.dart';
import 'package:travers_app/features/competitions/widgets/participant_form.dart';
import 'package:travers_app/features/judging/widgets/participant_card.dart';

class ParticipantsListScreen extends ConsumerStatefulWidget {
  final String competitionId;
  final bool canEdit;
  const ParticipantsListScreen({
    super.key,
    required this.competitionId,
    required this.canEdit,
  });

  @override
  ConsumerState<ParticipantsListScreen> createState() =>
      _ParticipantsListScreenState();
}

class _ParticipantsListScreenState
    extends ConsumerState<ParticipantsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participantsAsync = ref.watch(
      participantsStreamProvider(widget.competitionId),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Учасники змагань',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (widget.canEdit)
            IconButton(
              icon: const Icon(Icons.file_upload_outlined),
              tooltip: 'Імпортувати CSV',
              onPressed: () async {
                try {
                  final count = await ref
                      .read(participantsRepositoryProvider)
                      .importFromCsv(widget.competitionId);
                  if (mounted && count > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Успішно імпортовано $count учасників'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          AppSearchField(
            hintText: 'Пошук за іменем або командою...',
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
          ),

          Expanded(
            child: participantsAsync.when(
              data: (list) {
                final filteredList = list.where((p) {
                  return p.name.toLowerCase().contains(_searchQuery) ||
                      p.teamName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('Учасників не знайдено'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final p = filteredList[index];

                    final participantCard = Consumer(
                      builder: (context, ref, child) {
                        final isUnsynced =
                            ref
                                .watch(
                                  unsyncedParticipantProvider((
                                    compId: widget.competitionId,
                                    pId: p.id,
                                  )),
                                )
                                .value ??
                            false;

                        return ParticipantCard(
                          participant: p,
                          isUnsynced: isUnsynced,
                          canEdit: widget.canEdit,
                          onTap: widget.canEdit
                              ? () => _showParticipantForm(
                                  context,
                                  p,
                                  list.length,
                                )
                              : () {},
                        );
                      },
                    );

                    if (widget.canEdit) {
                      return Dismissible(
                        key: Key(p.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await DialogHelpers.showConfirmDialog(
                            context,
                            title: 'Видалити учасника?',
                            content:
                                'Ви впевнені, що хочете видалити учасника "${p.name}" з цього змагання?',
                            confirmText: 'Видалити',
                          );
                        },
                        onDismissed: (_) {
                          ref
                              .read(participantsRepositoryProvider)
                              .deleteParticipant(widget.competitionId, p.id);
                        },
                        child: participantCard,
                      );
                    } else {
                      return participantCard;
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Помилка: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: (widget.canEdit)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 4),
              child: FloatingActionButton(
                onPressed: () {
                  final currentList = participantsAsync.value ?? [];
                  _showParticipantForm(context, null, currentList.length);
                },
                backgroundColor: theme.primaryColor,
                child: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            )
          : null,
    );
  }

  void _showParticipantForm(
    BuildContext context,
    ParticipantModel? participant,
    int currentCount,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ParticipantFormBottomSheet(
        competitionId: widget.competitionId,
        participant: participant,
        currentCount: currentCount,
      ),
    );
  }
}
