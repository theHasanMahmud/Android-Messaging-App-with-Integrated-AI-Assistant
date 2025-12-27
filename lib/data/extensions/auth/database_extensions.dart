import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adda_time/core/di/dependency_injector.dart';
import 'package:adda_time/core/interfaces/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

extension DatabaseExtensions on FirebaseFirestore {
  Future<DocumentReference> currentUserDocument() async {
    final userOption = await getIt<IAuthRepository>().getSignedInUser();
    final user = userOption.getOrElse(() => throw Exception('Not authenticated'));

    return FirebaseFirestore.instance.collection('users').doc(user.id);
  }

  Future<DocumentReference> userDocument({required String userId}) async {
    return FirebaseFirestore.instance.collection('users').doc(userId);
  }
}

extension CollectionExtensions on DocumentReference {
  CollectionReference get userCollection => collection('users');
} 