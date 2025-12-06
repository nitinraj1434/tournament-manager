import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turnament/constants/app_constants.dart';
import 'package:turnament/models/tournament_model.dart';
import 'package:turnament/services/database_service.dart';
import 'package:turnament/widgets/custom_button.dart';
import 'package:turnament/widgets/custom_text_field.dart';

class CreateEditTournamentScreen extends StatefulWidget {
  final TournamentModel? tournament;

  const CreateEditTournamentScreen({super.key, this.tournament});

  @override
  State<CreateEditTournamentScreen> createState() =>
      _CreateEditTournamentScreenState();
}

class _CreateEditTournamentScreenState
    extends State<CreateEditTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _gameTypeController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _slotsController = TextEditingController();
  final _prizeController = TextEditingController();
  final _rulesController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _gameIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mapController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  String _status = 'draft';
  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.tournament != null) {
      final t = widget.tournament!;
      _titleController.text = t.title;
      _gameTypeController.text = t.gameType;
      _entryFeeController.text = t.entryFee.toString();
      _slotsController.text = t.slots.toString();
      _prizeController.text = t.prize.toString();
      _rulesController.text = t.rules;
      _imageUrlController.text = t.imageUrl;
      _gameIdController.text = t.gameId;
      _passwordController.text = t.password;
      _mapController.text = t.map;
      _selectedDate = t.date;
      // Parse time string if possible, otherwise default
      // Assuming time format "h:mm a"
      try {
        // Simple parsing logic or keep default
      } catch (_) {}
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _gameTypeController.dispose();
    _entryFeeController.dispose();
    _slotsController.dispose();
    _prizeController.dispose();
    _rulesController.dispose();
    _imageUrlController.dispose();
    _gameIdController.dispose();
    _passwordController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTournament() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final date = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final tournament = TournamentModel(
          id: widget.tournament?.id ?? '',
          title: _titleController.text.trim(),
          gameType: _gameTypeController.text.trim(),
          date: date,
          time: _selectedTime.format(context),
          entryFee: double.parse(_entryFeeController.text.trim()),
          slots: int.parse(_slotsController.text.trim()),
          prize: double.parse(_prizeController.text.trim()),
          rules: _rulesController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          status: _status,
          participants: widget.tournament?.participants ?? [],
          gameId: _gameIdController.text.trim(),
          password: _passwordController.text.trim(),
          map: _mapController.text.trim(),
        );

        if (widget.tournament == null) {
          await _dbService.createTournament(tournament);
        } else {
          await _dbService.updateTournament(tournament);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tournament saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.tournament == null ? 'Create Tournament' : 'Edit Tournament',
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Game Type (e.g. PUBG, Free Fire)',
                controller: _gameTypeController,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Map (e.g. Erangel, Sanhok)',
                controller: _mapController,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Entry Fee',
                      controller: _entryFeeController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Slots',
                      controller: _slotsController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Prize Pool',
                controller: _prizeController,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        DateFormat('MMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(
                    value: 'published',
                    child: Text('Published'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                ],
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Rules',
                controller: _rulesController,
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Image URL (Optional)',
                controller: _imageUrlController,
              ),
              const SizedBox(height: 24),
              const Text(
                'Room Details (Visible to joined players)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Room ID / Game ID',
                controller: _gameIdController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Tournament',
                onPressed: _saveTournament,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
