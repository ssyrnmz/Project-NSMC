import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/health_screening_repository.dart';
import '../../domain/health_screening.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class HealthScreeningModifyViewModel extends ChangeNotifier {
  //▫️Constructor:
  HealthScreeningModifyViewModel({
    required HealthScreeningRepository healthScreeningRepository,
    required AccountSession accountSession,
  }) : _healthScreeningRepository = healthScreeningRepository,
       _accountSession = accountSession;

  //▫️Variables:
  // Repositories
  final HealthScreeningRepository _healthScreeningRepository;
  final AccountSession _accountSession;

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // Image file picker function
  Future<Result<File?>> pickImage() async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to pick image for packages";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final imagePath = result.files.single.path;

        if (imagePath != null) {
          return Result.ok(File(imagePath));
        } else {
          _errorMessage =
              "The system could not retrieve file's path. Please try again.";
          return Result.error(Exception(_errorMessage));
        }
      } else {
        return Result.ok(null);
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      _errorMessage =
          "Unexpected error occurred during the image picking process, Please try again.";
      return Result.error(Exception(_errorMessage));
    }
  }

  // Create Health Screening Package based on input
  Future<Result> addPackage(HealthScreening hsp, File image) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to add images for the carousel.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    // Save image first to folder, then save the new screening details into the database
    try {
      // Save image to public server folder
      final imageResult = await _healthScreeningRepository.uploadImage(image);

      switch (imageResult) {
        case Ok<String>():
          debugPrint('Saved Image: ${imageResult.value}');
        case Error<String>():
          _errorMessage =
              "There's an issue when trying to save uploaded images to the system. Please try again.";
          debugPrint('Failed to saved image: ${imageResult.error}');
          return imageResult;
      }

      // Health package data
      final newHsp = HealthScreening(
        id: 0,
        name: hsp.name,
        price: hsp.price,
        description: hsp.description,
        included: hsp.included,
        image: imageResult.value,
        category: hsp.category, // FIX: was missing — category never sent to DB
        archived: hsp.archived,
        updatedAt: hsp.updatedAt,
      );

      // Save details into the database
      final result = await _healthScreeningRepository.addHealthScreening(
        newHsp,
      );
      switch (result) {
        case Ok<HealthScreening>():
          debugPrint('Add package: ${result.value}');
        case Error<HealthScreening>():
          _errorMessage =
              "There's a system issue during creation of ${newHsp.name}'s data. Please try again or check for issues surrounding application.";
          debugPrint('Failed to add package: ${result.error}');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update package's detail with updated details
  Future<Result> editPackage(HealthScreening hsp, File? image) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to add images for the carousel.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    // Save image first to folder, then save the updated screening details into the database
    try {
      // Save image to public server folder
      String imageURL = hsp.image;

      if (image != null) {
        final imageResult = await _healthScreeningRepository.uploadImage(image);
        switch (imageResult) {
          case Ok<String>():
            imageURL = imageResult.value;
            debugPrint('Saved Image: ${imageResult.value}');
          case Error<String>():
            _errorMessage =
                "There's an issue when trying to save uploaded images to the system. Please try again.";
            debugPrint('Failed to saved image: ${imageResult.error}');
            return imageResult;
        }
      }

      // Health package data
      final newHsp = HealthScreening(
        id: hsp.id,
        name: hsp.name,
        price: hsp.price,
        description: hsp.description,
        included: hsp.included,
        image: imageURL,
        category: hsp.category, // FIX: was missing — category never sent to DB
        archived: hsp.archived,
        updatedAt: hsp.updatedAt,
      );

      // Save details into the database
      final result = await _healthScreeningRepository.editHealthScreening(
        newHsp,
      );
      switch (result) {
        case Ok<HealthScreening>():
          debugPrint('Update package: ${result.value}');
        case Error<HealthScreening>():
          _errorMessage =
              "There's a system issue during update of ${newHsp.name}'s data. Please try again or check for issues surrounding application.";
          debugPrint('Failed to update package: ${result.error}');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete/archive package's details
  Future<Result> deletePackage(HealthScreening hsp) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to add images for the carousel.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    // Archive/delete package by changing archive status
    HealthScreening deletePackage = HealthScreening(
      id: hsp.id,
      name: hsp.name,
      price: hsp.price,
      description: hsp.description,
      included: hsp.included,
      image: hsp.image,
      archived: true,
      updatedAt: hsp.updatedAt,
    );

    try {
      final result = await _healthScreeningRepository.editHealthScreening(
        deletePackage,
      );
      switch (result) {
        case Ok<HealthScreening>():
          debugPrint('Deleted package: ${result.value}');
        case Error<HealthScreening>():
          _errorMessage =
              "There's a system issue during deletion of ${hsp.name}'s data. Please try again or check for issues surrounding application.";
          debugPrint('Failed to delete package: ${result.error}');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
