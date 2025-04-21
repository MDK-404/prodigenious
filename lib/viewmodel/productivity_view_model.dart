import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/analytics_service.dart';

class ProductivityViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  String? _insight;
  bool _isLoading = false;

  String? get insight => _insight;
  bool get isLoading => _isLoading;

  Future<void> loadInsight() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _insight = 'User not logged in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final uid = currentUser.uid;

      final storedInsight = await _analyticsService.getStoredInsight(uid);

      if (storedInsight != null) {
        _insight = storedInsight;
      } else {
        _insight = await _analyticsService.generateProductivityInsight();
      }
    } catch (e) {
      _insight = 'Error loading insight: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshInsight() async {
    _isLoading = true;
    notifyListeners();

    try {
      _insight = await _analyticsService.generateProductivityInsight();
    } catch (e) {
      _insight = 'Error refreshing insight: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
