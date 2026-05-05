import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travers_app/models/competition.dart';
import 'package:travers_app/providers/competition_provider.dart';
import 'package:travers_app/screens/competition_details.dart';
import 'package:travers_app/utils/error_mapper.dart';
import 'package:travers_app/utils/snackbar_utils.dart';
import 'package:travers_app/widgets/custom_date_field.dart';
import 'package:travers_app/widgets/custom_text_field.dart';
import 'package:flutter/services.dart';

class AddCompetitionScreen extends ConsumerStatefulWidget {
  final CompetitionModel? competition;
  const AddCompetitionScreen({super.key, this.competition});
  @override
  ConsumerState<AddCompetitionScreen> createState() =>
      _AddCompetitionScreenState();
}

class _AddCompetitionScreenState extends ConsumerState<AddCompetitionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _location;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.competition?.title ?? '';
    _location = widget.competition?.location ?? '';
    _startDate = widget.competition?.startDate;
    _endDate = widget.competition?.endDate;
  }

  Future<void> _selectDateRange() async {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: now.subtract(const Duration(days: 30)),
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
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _saveCompetition() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_startDate == null || _endDate == null) {
      SnackbarUtils.show(
        context,
        'Будь ласка, оберіть дати проведення змагання',
        isError: true,
      );
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
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final isEditing = widget.competition != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black54),
        ),
        title: Text(
          isEditing ? 'Редагувати змагання' : 'Нове змагання',
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: 'Назва змагання',
                        icon: Icons.title,
                        initialValue: _title,
                        onSaved: (value) => _title = value ?? '',
                        validator: (value) =>
                            value != null && value.trim().isEmpty
                            ? 'Введіть назву'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Локація',
                        icon: Icons.location_on_outlined,
                        initialValue: _location,
                        onSaved: (value) => _location = value ?? '',
                        validator: (value) =>
                            value != null && value.trim().isEmpty
                            ? 'Введіть локацію'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: CustomDateField(
                              label: 'Початок',
                              icon: Icons.calendar_today_outlined,
                              valueText: _startDate == null
                                  ? 'дд.мм.рррр'
                                  : dateFormatter.format(_startDate!),
                              onTap: _selectDateRange,
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
                              onTap: _selectDateRange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCompetition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Зберегти',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
