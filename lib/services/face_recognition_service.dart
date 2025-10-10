import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img_lib;
import '../config/app_config.dart';

class FaceRecognitionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Detect faces in an image
  Future<List<Face>> detectFaces(InputImage inputImage) async {
    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      throw 'Failed to detect faces: $e';
    }
  }

  // Detect faces from camera image
  Future<List<Face>> detectFacesFromCamera(CameraImage cameraImage) async {
    try {
      final allBytes = BytesBuilder();
      for (final Plane plane in cameraImage.planes) {
        allBytes.add(plane.bytes);
      }
      final bytes = allBytes.toBytes();

      final imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble()
      );

      final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
              InputImageFormat.nv21;

      final inputImageMetadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: cameraImage.planes.first.bytesPerRow,
      );

      final InputImage inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageMetadata,
      );

      return await detectFaces(inputImage);
    } catch (e) {
      throw 'Failed to process camera image: $e';
    }
  }

  // Detect faces from file
  Future<List<Face>> detectFacesFromFile(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      return await detectFaces(inputImage);
    } catch (e) {
      throw 'Failed to process image file: $e';
    }
  }

  // Extract face features for comparison
  Map<String, dynamic> extractFaceFeatures(Face face) {
    return {
      'boundingBox': {
        'left': face.boundingBox.left,
        'top': face.boundingBox.top,
        'right': face.boundingBox.right,
        'bottom': face.boundingBox.bottom,
      },
      'headEulerAngleY': face.headEulerAngleY,
      'headEulerAngleZ': face.headEulerAngleZ,
      'leftEyeOpenProbability': face.leftEyeOpenProbability,
      'rightEyeOpenProbability': face.rightEyeOpenProbability,
      'smilingProbability': face.smilingProbability,
    };
  }

  // Simple face comparison (basic implementation)
  double compareFaces(Map<String, dynamic> face1, Map<String, dynamic> face2) {
    try {
      // This is a simplified comparison. In production, use a proper face recognition model
      double score = 0.0;
      int totalFeatures = 0;

      // Compare bounding box size
      final box1 = face1['boundingBox'];
      final box2 = face2['boundingBox'];

      double width1 = (box1['right'] - box1['left']).abs();
      double height1 = (box1['bottom'] - box1['top']).abs();
      double width2 = (box2['right'] - box2['left']).abs();
      double height2 = (box2['bottom'] - box2['top']).abs();

      double sizeSimilarity =
          1 - ((width1 - width2).abs() + (height1 - height2).abs()) / (width1 + height1);
      score += sizeSimilarity.clamp(0.0, 1.0);
      totalFeatures++;

      // Compare head angles
      if (face1['headEulerAngleY'] != null && face2['headEulerAngleY'] != null) {
        double angleDiff = (face1['headEulerAngleY'] - face2['headEulerAngleY']).abs();
        score += (1 - (angleDiff / 180)).clamp(0.0, 1.0);
        totalFeatures++;
      }

      return totalFeatures > 0 ? score / totalFeatures : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Upload face image to Firebase Storage
  Future<String> uploadFaceImage(File imageFile, String userId, String type) async {
    try {
      final String fileName = '${userId}_${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('${AppConfig.faceImagesPath}$fileName');

      // Compress image before upload
      final bytes = await imageFile.readAsBytes();
      final image = img_lib.decodeImage(bytes);

      if (image != null) {
        final resized = img_lib.copyResize(image, width: 800);
        final compressed = img_lib.encodeJpg(resized, quality: 85);

        await ref.putData(Uint8List.fromList(compressed));
        final String downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw 'Failed to process image';
      }
    } catch (e) {
      throw 'Failed to upload face image: $e';
    }
  }

  // Save face data to Firestore
  Future<void> saveFaceData(
    String userId,
    Map<String, dynamic> faceFeatures,
    String imageUrl,
  ) async {
    try {
      await _firestore.collection(AppConfig.faceDataCollection).doc(userId).set({
        'userId': userId,
        'faceFeatures': faceFeatures,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save face data: $e';
    }
  }

  // Get stored face data for a user
  Future<Map<String, dynamic>?> getStoredFaceData(String userId) async {
    try {
      final doc =
          await _firestore.collection(AppConfig.faceDataCollection).doc(userId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch face data: $e';
    }
  }

  // Verify face against stored data
  Future<bool> verifyFace(Face detectedFace, String userId) async {
    try {
      final storedData = await getStoredFaceData(userId);

      if (storedData == null || storedData['faceFeatures'] == null) {
        throw 'No face data found for this user. Please register your face first.';
      }

      final detectedFeatures = extractFaceFeatures(detectedFace);
      final storedFeatures = storedData['faceFeatures'] as Map<String, dynamic>;

      final similarity = compareFaces(detectedFeatures, storedFeatures);

      return similarity >= AppConfig.faceMatchThreshold;
    } catch (e) {
      throw 'Face verification failed: $e';
    }
  }

  // Check if face is properly positioned for capture
  bool isFaceProperlyPositioned(Face face, Size imageSize) {
    // Check if face is centered and large enough
    final boundingBox = face.boundingBox;
    final faceWidth = boundingBox.width;
    final faceHeight = boundingBox.height;

    // Face should occupy at least 30% of the image
    final minSize = imageSize.width * 0.3;

    if (faceWidth < minSize || faceHeight < minSize) {
      return false;
    }

    // Check if face is roughly centered
    final centerX = boundingBox.left + (faceWidth / 2);
    final centerY = boundingBox.top + (faceHeight / 2);
    final imageCenterX = imageSize.width / 2;
    final imageCenterY = imageSize.height / 2;

    final horizontalOffset = (centerX - imageCenterX).abs();
    final verticalOffset = (centerY - imageCenterY).abs();

    // Face should be within 25% of image center
    final maxOffset = imageSize.width * 0.25;

    return horizontalOffset < maxOffset && verticalOffset < maxOffset;
  }

  // Dispose detector
  void dispose() {
    _faceDetector.close();
  }
}
