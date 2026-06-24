import 'package:flutter/material.dart';
import '../Model/slot_model.dart';
import '../Repository/slot_repository.dart';

class SlotService extends ChangeNotifier {
  final SlotRepository _repository;

  List<SlotModel> _slots = [];
  bool _isLoading = false;
  String _error = '';

  List<SlotModel> get slots => _slots;
  bool get isLoading => _isLoading;
  String get error => _error;

  SlotService(this._repository);

  Future<List<SlotModel>> fetchSlots({
    required int sportClubId,
    int page = 1,
    int limit = 10,
    bool available = true,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final dto = await _repository.getSlots(
        sportClubId: sportClubId,
        page: page,
        limit: limit,
        available: available,
      );
      _slots = dto.data;
      _isLoading = false;
      notifyListeners();
      return _slots;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<SlotModel> getSlotById(int slotId) async {
    try {
      return await _repository.getSlotById(slotId);
    } catch (e) {
      rethrow;
    }
  }

  void clearSlots() {
    _slots = [];
    notifyListeners();
  }
}
