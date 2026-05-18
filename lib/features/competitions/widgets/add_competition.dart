import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/utils/base_bottom_sheet.dart';
import 'package:travers_app/features/competitions/screens/competition_details.dart';
import 'package:travers_app/core/utils/error_mapper.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/core/widgets/custom_date_field.dart';
import 'package:travers_app/core/widgets/custom_text_field.dart';

class AddCompetitionBottomSheet extends ConsumerStatefulWidget {
  final CompetitionModel? competition;
  const AddCompetitionBottomSheet({super.key, this.competition});
  @override
  ConsumerState<AddCompetitionBottomSheet> createState() =>
      _AddCompetitionBottomSheetState();
}

class _AddCompetitionBottomSheetState
    extends ConsumerState<AddCompetitionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _location;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  String? _dateError;

  @override
  void initState() {
    super.initState();
    _title = widget.competition?.title ?? '';
    _location = widget.competition?.location ?? '';
    _startDate = widget.competition?.startDate;
    _endDate = widget.competition?.endDate;
  }

  Future<void> _selectDate(bool isStartDate) async {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final initialDate = isStartDate
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final firstDate = isStartDate
        ? now.subtract(const Duration(days: 30))
        : (_startDate ?? now.subtract(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateError = null;
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveCompetition() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_startDate == null || _endDate == null) {
      setState(() {
        _dateError = 'Оберіть дати проведення змагання';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final savedCompetition = await ref
          .read(competitionRepositoryProvider)
          .saveCompetition(
            existingCompetition: widget.competition,
            title: _title,
            location: _location,
            startDate: _startDate!,
            endDate: _endDate!,
          );

      if (mounted) {
        if (widget.competition != null) {
          Navigator.pop(context);
        } else {
          if (widget.competition == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompetitionDetailsScreen(
                  competitionId: savedCompetition.id,
                  initialCompetition: savedCompetition,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.show(
          context,
          ErrorMapper.getHumanReadableMessage(e),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final isEditing = widget.competition != null;

    return BaseBottomSheet(
      title: isEditing ? 'Редагувати змагання' : 'Нове змагання',
      bottomButton: PrimarySubmitButton(
        text: isEditing ? 'Зберегти' : 'Додати',
        isLoading: _isLoading,
        onPressed: _saveCompetition,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                label: 'Назва змагання',
                icon: Icons.title,
                initialValue: _title,
                onSaved: (value) => _title = value ?? '',
                validator: (value) => value != null && value.trim().isEmpty
                    ? 'Введіть назву'
                    : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Локація',
                icon: Icons.location_on_outlined,
                initialValue: _location,
                onSaved: (value) => _location = value ?? '',
                validator: (value) => value != null && value.trim().isEmpty
                    ? 'Введіть локацію'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomDateField(
                      label: 'Початок',
                      icon: Icons.calendar_today_outlined,
                      valueText: _startDate == null
                          ? 'дд.мм.рррр'
                          : dateFormatter.format(_startDate!),
                      onTap: () => _selectDate(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDateField(
                      label: 'Завершення',
                      icon: Icons.calendar_today_outlined,
                      valueText: _endDate == null
                          ? 'дд.мм.рррр'
                          : dateFormatter.format(_endDate!),
                      onTap: () => _selectDate(false),
                    ),
                  ),
                ],
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    _dateError!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
