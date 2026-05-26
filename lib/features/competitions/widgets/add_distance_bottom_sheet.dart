import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/utils/app_decorations.dart';
import 'package:travers_app/core/widgets/base_bottom_sheet.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import '../../../core/utils/error_mapper.dart';

class AddDistanceBottomSheet extends ConsumerStatefulWidget {
  final String competitionId;
  final Distance? initialDistance;

  const AddDistanceBottomSheet({
    super.key,
    required this.competitionId,
    this.initialDistance,
  });

  @override
  ConsumerState<AddDistanceBottomSheet> createState() =>
      _AddDistanceBottomSheetState();
}

class _AddDistanceBottomSheetState
    extends ConsumerState<AddDistanceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  DistanceType _type = DistanceType.obstacleCourse;
  DistanceView _view = DistanceView.individual;
  int _classLevel = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialDistance != null) {
      _description = widget.initialDistance!.description ?? '';
      _type = widget.initialDistance!.type;
      _view = widget.initialDistance!.view;
      _classLevel = widget.initialDistance!.classLevel;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final repository = ref.read(competitionRepositoryProvider);

      if (widget.initialDistance != null) {
        final updatedDistance = widget.initialDistance!.copyWith(
          type: _type,
          view: _view,
          classLevel: _classLevel,
          description: _description,
        );

        repository.updateDistance(
          competitionId: widget.competitionId,
          updatedDistance: updatedDistance,
        );
      } else {
        repository.addDistance(
          competitionId: widget.competitionId,
          description: _description,
          type: _type,
          view: _view,
          classLevel: _classLevel,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      SnackbarUtils.show(
        context,
        ErrorMapper.getHumanReadableMessage(e),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialDistance != null;

    return BaseBottomSheet(
      title: isEditing ? 'Змінити дистанцію' : 'Додати дистанцію',
      bottomButton: PrimarySubmitButton(
        text: isEditing ? 'Зберегти' : 'Додати дистанцію',
        onPressed: _submit,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<DistanceType>(
                value: _type,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: AppDecorations.inputField(
                  theme: theme,
                  hint: 'Тип',
                  icon: Icons.category_outlined,
                ),
                items: DistanceType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _classLevel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: AppDecorations.inputField(
                        theme: theme,
                        hint: 'Клас',
                        icon: Icons.category_outlined,
                      ),
                      items: List.generate(6, (i) => i + 1)
                          .map(
                            (lvl) => DropdownMenuItem(
                              value: lvl,
                              child: Text('$lvl клас'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _classLevel = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<DistanceView>(
                      isExpanded: true,
                      value: _view,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: AppDecorations.inputField(
                        theme: theme,
                        hint: 'Вид',
                        icon: Icons.category_outlined,
                      ),
                      items: DistanceView.values
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(
                                v.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _view = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                initialValue: widget.initialDistance?.description,
                decoration: AppDecorations.inputField(
                  theme: theme,
                  hint: 'Додаткова інформація (опціонально)',
                  icon: Icons.notes_outlined,
                  borderRadius: 20.0,
                  alignLabelWithHint: true,
                ),
                onSaved: (value) => _description = value ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
