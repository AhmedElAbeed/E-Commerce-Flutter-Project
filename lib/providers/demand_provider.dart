import 'package:flutter/material.dart';
import '../models/demand_model.dart';
import '../services/demand_service.dart';

class DemandProvider with ChangeNotifier {
  final DemandService demandService;
  List<DemandModel> _demands = [];
  bool _isLoading = false;
  String? _error;

  DemandProvider(this.demandService);

  List<DemandModel> get demands => _demands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    // Call this when your app starts to fix any existing invalid data
    await demandService.fixInvalidProductsData();
  }

  Future<void> loadUserDemands(String userEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _demands = await demandService.getUserDemands(userEmail);
    } catch (e) {
      _error = 'Failed to load demands: ${e.toString()}';
      print('❌ Error loading user demands: $_error');
      _demands = []; // Reset to empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllDemands() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _demands = await demandService.getAllDemands();
    } catch (e) {
      _error = 'Failed to load demands: ${e.toString()}';
      print('❌ Error loading all demands: $_error');
      _demands = []; // Reset to empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> createDemand(DemandModel demand) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await demandService.addDemand(demand);
      await loadUserDemands(demand.userEmail);
      return id;
    } catch (e) {
      _error = 'Failed to create demand: ${e.toString()}';
      print('❌ Error creating demand: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await demandService.updateDemandStatus(id, status);
      await loadAllDemands();
    } catch (e) {
      _error = 'Failed to update status: ${e.toString()}';
      print('❌ Error updating demand status: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}