import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/repositories/participant_repository.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/widgets/base_bottom_sheet.dart';
import 'package:travers_app/core/widgets/custom_text_field.dart';

class ParticipantFormBottomSheet extends ConsumerStatefulWidget {
  final String competitionId;
  final ParticipantModel? participant;
  final int currentCount;

  const ParticipantFormBottomSheet({
    super.key,
    required this.competitionId,
    this.participant,
    required this.currentCount,
  });

  @override
  ConsumerState<ParticipantFormBottomSheet> createState() =>
      _ParticipantFormBottomSheetState();
}

class _ParticipantFormBottomSheetState
    extends ConsumerState<ParticipantFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _teamCtrl;
  late TextEditingController _coachCtrl;
  late TextEditingController _regionCtrl;
  late TextEditingController _yearCtrl;
  late Gender _gender;

  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.participant;
    final initialNumber = p != null ? p.startNumber : (widget.currentCount + 1);

    _numberCtrl = TextEditingController(text: '$initialNumber');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _teamCtrl = TextEditingController(text: p?.teamName ?? '');
    _coachCtrl = TextEditingController(text: p?.coachName ?? '');
    _regionCtrl = TextEditingController(text: p?.region ?? '');
    _yearCtrl = TextEditingController(
      text: p != null ? '${p.birthYear}' : '2005',
    );
    _gender = p?.gender ?? Gender.male;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _teamCtrl.dispose();
    _coachCtrl.dispose();
    _regionCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    final newParticipant = ParticipantModel(
      id: widget.participant?.id ?? '',
      startNumber: int.parse(_numberCtrl.text),
      name: _nameCtrl.text.trim(),
      teamName: _teamCtrl.text.trim(),
      coachName: _coachCtrl.text.trim(),
      gender: _gender,
      region: _regionCtrl.text.trim(),
      birthYear: int.parse(_yearCtrl.text),
    );

    try {
      await ref
          .read(participantsRepositoryProvider)
          .saveParticipant(widget.competitionId, newParticipant);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Видалити учасника?',
      content:
          'Ви впевнені, що хочете видалити учасника "${widget.participant!.name}" з цього змагання?',
      confirmText: 'Видалити',
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    try {
      await ref
          .read(participantsRepositoryProvider)
          .deleteParticipant(widget.competitionId, widget.participant!.id);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.participant != null;

    return BaseBottomSheet(
      title: isEdit ? 'Редагувати учасника' : 'Додати учасника',

      bottomButton: Column(
        children: [
          if (isEdit) ...[
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              label: const Text(
                'Видалити учасника',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              onPressed: _isSaving ? null : _handleDelete,
            ),
          ],
          PrimarySubmitButton(
            text: isEdit ? 'Зберегти зміни' : 'Додати учасника',
            isLoading: _isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),

      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _numberCtrl,
                      label: '№',
                      icon: Icons.tag,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? '?' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _yearCtrl,
                      label: 'Рік нар.',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return '!';
                        final year = int.tryParse(v);
                        if (year == null || year < 1950 || year > 2020) {
                          return 'Помилка';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameCtrl,
                label: 'ПІБ учасника',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Введіть ім\'я' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _teamCtrl,
                label: 'Команда / Клуб',
                icon: Icons.shield_outlined,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _coachCtrl,
                label: 'Тренер',
                icon: Icons.sports_outlined,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _regionCtrl,
                label: 'Область / Регіон',
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 20),

              _GenderSelector(
                selectedGender: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final Gender selectedGender;
  final ValueChanged<Gender> onChanged;

  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Стать:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            children: [
              Radio<Gender>(
                value: Gender.male,
                groupValue: selectedGender,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (v) => onChanged(v!),
              ),
              const Text('Ч', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 16),
              Radio<Gender>(
                value: Gender.female,
                groupValue: selectedGender,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (v) => onChanged(v!),
              ),
              const Text('Ж', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
