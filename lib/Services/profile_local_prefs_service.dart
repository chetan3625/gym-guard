import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

class LocalProfileSeed {
  const LocalProfileSeed({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.gymName = '',
    this.dob = '',
    this.gender = '',
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String gymName;
  final String dob;
  final String gender;

  bool get hasAnyValue =>
      firstName.isNotEmpty ||
      lastName.isNotEmpty ||
      phone.isNotEmpty ||
      email.isNotEmpty ||
      gymName.isNotEmpty ||
      dob.isNotEmpty ||
      gender.isNotEmpty;
}

class ProfileLocalPrefsService {
  static const _firstNameKey = 'profile_first_name';
  static const _lastNameKey = 'profile_last_name';
  static const _phoneKey = 'profile_phone';
  static const _emailKey = 'profile_email';
  static const _gymNameKey = 'profile_gym_name';
  static const _dobKey = 'profile_dob';
  static const _genderKey = 'profile_gender';
  final GetStorage _box = GetStorage();

  Future<void> saveFromSignup({
    required String fullName,
    required String phone,
  }) async {
    final split = _splitFullName(fullName);
    await saveProfileSeed(
      firstName: split.firstName,
      lastName: split.lastName,
      phone: phone,
    );
  }

  Future<void> saveProfileSeed({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? gymName,
    String? dob,
    String? gender,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _setStringOrRemove(prefs, _firstNameKey, firstName);
      await _setStringOrRemove(prefs, _lastNameKey, lastName);
      await _setStringOrRemove(prefs, _phoneKey, phone);
      await _setStringOrRemove(prefs, _emailKey, email);
      await _setStringOrRemove(prefs, _gymNameKey, gymName);
      await _setStringOrRemove(prefs, _dobKey, dob);
      await _setStringOrRemove(prefs, _genderKey, gender);
    } catch (e) {
      debugPrint('SharedPreferences unavailable, fallback to GetStorage: $e');
    } finally {
      await _setStringOrRemoveBox(_firstNameKey, firstName);
      await _setStringOrRemoveBox(_lastNameKey, lastName);
      await _setStringOrRemoveBox(_phoneKey, phone);
      await _setStringOrRemoveBox(_emailKey, email);
      await _setStringOrRemoveBox(_gymNameKey, gymName);
      await _setStringOrRemoveBox(_dobKey, dob);
      await _setStringOrRemoveBox(_genderKey, gender);
    }
  }

  Future<LocalProfileSeed> getProfileSeed() async {
    LocalProfileSeed prefsSeed = const LocalProfileSeed();
    try {
      final prefs = await SharedPreferences.getInstance();
      prefsSeed = LocalProfileSeed(
        firstName: (prefs.getString(_firstNameKey) ?? '').trim(),
        lastName: (prefs.getString(_lastNameKey) ?? '').trim(),
        phone: (prefs.getString(_phoneKey) ?? '').trim(),
        email: (prefs.getString(_emailKey) ?? '').trim(),
        gymName: (prefs.getString(_gymNameKey) ?? '').trim(),
        dob: (prefs.getString(_dobKey) ?? '').trim(),
        gender: (prefs.getString(_genderKey) ?? '').trim(),
      );
    } catch (e) {
      debugPrint('SharedPreferences read failed, using GetStorage seed: $e');
    }

    final boxSeed = _getSeedFromBox();
    return LocalProfileSeed(
      firstName: _pickPreferred(prefsSeed.firstName, boxSeed.firstName),
      lastName: _pickPreferred(prefsSeed.lastName, boxSeed.lastName),
      phone: _pickPreferred(prefsSeed.phone, boxSeed.phone),
      email: _pickPreferred(prefsSeed.email, boxSeed.email),
      gymName: _pickPreferred(prefsSeed.gymName, boxSeed.gymName),
      dob: _pickPreferred(prefsSeed.dob, boxSeed.dob),
      gender: _pickPreferred(prefsSeed.gender, boxSeed.gender),
    );
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_firstNameKey);
      await prefs.remove(_lastNameKey);
      await prefs.remove(_phoneKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_gymNameKey);
      await prefs.remove(_dobKey);
      await prefs.remove(_genderKey);
    } catch (e) {
      debugPrint('SharedPreferences clear failed: $e');
    } finally {
      await _box.remove(_firstNameKey);
      await _box.remove(_lastNameKey);
      await _box.remove(_phoneKey);
      await _box.remove(_emailKey);
      await _box.remove(_gymNameKey);
      await _box.remove(_dobKey);
      await _box.remove(_genderKey);
    }
  }

  Future<void> _setStringOrRemove(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null) return;
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, normalized);
  }

  Future<void> _setStringOrRemoveBox(String key, String? value) async {
    if (value == null) return;
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await _box.remove(key);
      return;
    }
    await _box.write(key, normalized);
  }

  LocalProfileSeed _getSeedFromBox() {
    return LocalProfileSeed(
      firstName: (_box.read<String>(_firstNameKey) ?? '').trim(),
      lastName: (_box.read<String>(_lastNameKey) ?? '').trim(),
      phone: (_box.read<String>(_phoneKey) ?? '').trim(),
      email: (_box.read<String>(_emailKey) ?? '').trim(),
      gymName: (_box.read<String>(_gymNameKey) ?? '').trim(),
      dob: (_box.read<String>(_dobKey) ?? '').trim(),
      gender: (_box.read<String>(_genderKey) ?? '').trim(),
    );
  }

  String _pickPreferred(String primary, String fallback) {
    final normalizedPrimary = primary.trim();
    if (normalizedPrimary.isNotEmpty) return normalizedPrimary;
    return fallback.trim();
  }

  ({String firstName, String lastName}) _splitFullName(String rawName) {
    final parts = rawName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return (firstName: '', lastName: '');
    }
    if (parts.length == 1) {
      return (firstName: parts.first, lastName: '');
    }
    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }
}
