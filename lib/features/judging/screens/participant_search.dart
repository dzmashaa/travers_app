import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/judging/providers/judge_provider.dart';
import 'package:travers_app/features/judging/providers/participants_provider.dart';
import 'package:travers_app/features/judging/widgets/participant_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Твої імпорти моделей, карток та утиліт

class ParticipantSearchScreen extends ConsumerStatefulWidget {
  final String competitionId;
  final JudgeAssignment assignment;

  const ParticipantSearchScreen({
    super.key,
    required this.competitionId,
    required this.assignment,
  });

  @override
  ConsumerState<ParticipantSearchScreen> createState() =>
      _ParticipantSearchScreenState();
}

class _ParticipantSearchScreenState
    extends ConsumerState<ParticipantSearchScreen> {
  String _searchQuery = '';
  final Set<ParticipantModel> _selectedBunchParticipants = {};

  bool get isIndividual =>
      widget.assignment.distance.view == DistanceView.individual;
  bool get isTeam => widget.assignment.distance.view == DistanceView.team;
  bool get isPair => widget.assignment.distance.view == DistanceView.pair;

  void _toggleParticipantSelection(ParticipantModel participant) {
    setState(() {
      if (_selectedBunchParticipants.contains(participant)) {
        _selectedBunchParticipants.remove(participant);
      } else {
        if (_selectedBunchParticipants.length < 2) {
          _selectedBunchParticipants.add(participant);
        } else {
          SnackbarUtils.show(context, "Вже обрано 2 учасників", isError: true);
        }
      }
    });
  }

  Map<String, int> _getFilteredTeams(List<ParticipantModel> participants) {
    final Map<String, int> teamCounts = {};
    for (final p in participants) {
      teamCounts[p.teamName] = (teamCounts[p.teamName] ?? 0) + 1;
    }

    if (_searchQuery.isEmpty) return teamCounts;

    final query = _searchQuery.toLowerCase();
    teamCounts.removeWhere(
      (teamName, _) => !teamName.toLowerCase().contains(query),
    );
    return teamCounts;
  }

  List<ParticipantModel> _getFilteredParticipants(
    List<ParticipantModel> participants,
  ) {
    if (_searchQuery.isEmpty) return participants;

    final query = _searchQuery.toLowerCase();
    return participants.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.startNumber.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participantsAsync = ref.watch(
      competitionParticipantsProvider(widget.competitionId),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      bottomNavigationBar: isPair
          ? _PairBottomBar(
              selectedCount: _selectedBunchParticipants.length,
              theme: theme,
              onStart: () {
                /* TODO: Перехід до зв'язки */
              },
            )
          : null,
      body: Column(
        children: [
          const SizedBox(height: 16),
          _SearchBar(
            isTeam: isTeam,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: participantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Помилка: $err')),
              data: (participants) {
                if (participants.isEmpty) {
                  return Center(
                    child: Text(
                      'Учасників не знайдено',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  );
                }
                if (isTeam) {
                  final filteredTeams = _getFilteredTeams(participants);
                  return _TeamList(teams: filteredTeams);
                } else {
                  final filteredList = _getFilteredParticipants(participants);
                  return _ParticipantList(
                    participants: filteredList,
                    selectedParticipants: _selectedBunchParticipants,
                    isPairMode: isPair,
                    onToggleSelect: _toggleParticipantSelection,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTeam ? 'Пошук команди' : 'Пошук учасника',
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.assignment.block.blockName} (${widget.assignment.distance.view.displayName})',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isTeam;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.isTeam, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: isTeam ? 'Назва команди...' : 'Номер або прізвище...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  final Map<String, int> teams;

  const _TeamList({required this.teams});

  @override
  Widget build(BuildContext context) {
    final teamNames = teams.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: teamNames.length,
      itemBuilder: (context, index) {
        final teamName = teamNames[index];
        return TeamCard(
          teamName: teamName,
          onTap: () {
            /* TODO: Перехід до суддівства команди */
          },
        );
      },
    );
  }
}

class _ParticipantList extends StatelessWidget {
  final List<ParticipantModel> participants;
  final Set<ParticipantModel> selectedParticipants;
  final bool isPairMode;
  final ValueChanged<ParticipantModel> onToggleSelect;

  const _ParticipantList({
    required this.participants,
    required this.selectedParticipants,
    required this.isPairMode,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final isSelected = selectedParticipants.contains(participant);

        return ParticipantCard(
          participant: participant,
          isSelectableMode: isPairMode,
          isSelected: isSelected,
          onTap: () {
            if (!isPairMode) {
              /* TODO: Перехід до суддівства 1 учасника */
            }
          },
          onSelectChanged: (_) => onToggleSelect(participant),
        );
      },
    );
  }
}

class _PairBottomBar extends StatelessWidget {
  final int selectedCount;
  final ThemeData theme;
  final VoidCallback onStart;

  const _PairBottomBar({
    required this.selectedCount,
    required this.theme,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = selectedCount == 2;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Учасники зв\'язки',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Обрано $selectedCount/2',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isReady ? theme.primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: isReady ? onStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Почати',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
