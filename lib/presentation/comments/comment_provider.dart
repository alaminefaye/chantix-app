import 'package:flutter/foundation.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';
import 'dart:io';

class CommentProvider with ChangeNotifier {
  final CommentRepository _repository = CommentRepository();

  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedProjectId;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedProjectId => _selectedProjectId;

  void setSelectedProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  Future<void> loadComments({Map<String, dynamic>? filters}) async {
    if (_selectedProjectId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _repository.getComments(
        projectId: _selectedProjectId!,
        filters: filters,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required String content,
    int? parentId,
    List<File>? attachments,
  }) async {
    if (_selectedProjectId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createComment(
        projectId: _selectedProjectId!,
        content: content,
        parentId: parentId,
        attachments: attachments,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadComments();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComment(int id) async {
    if (_selectedProjectId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteComment(id, _selectedProjectId!);
      _isLoading = false;

      if (success) {
        _comments.removeWhere((c) => c.id == id);
        // Supprimer aussi des réponses si c'est un commentaire parent
        _comments.removeWhere((c) => c.parentId == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

