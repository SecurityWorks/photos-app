import 'package:collection/collection.dart';
import 'package:photos/models/subscription.dart';

class UserDetails {
  final String email;
  final int usage;
  final int fileCount;
  final int sharedCollectionsCount;
  final Subscription subscription;
  final FamilyData familyData;

  UserDetails(
    this.email,
    this.usage,
    this.fileCount,
    this.sharedCollectionsCount,
    this.subscription,
    this.familyData,
  );

  bool isPartOfFamily() {
    return familyData?.members?.isNotEmpty ?? false;
  }

  bool isFamilyAdmin() {
    assert(isPartOfFamily(), "verify user is part of family before calling");
    final FamilyMember currentUserMember = familyData?.members
        ?.firstWhere((element) => element.email.trim() == email.trim());
    return currentUserMember.isAdmin;
  }

  // getFamilyOrPersonalUsage will return total usage for family if user
  // belong to family group. Otherwise, it will return storage consumed by
  // current user
  int getFamilyOrPersonalUsage() {
    return isPartOfFamily() ? familyData.getTotalUsage() : usage;
  }

  int getPersonalUsage() {
    return usage;
  }

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      map['email'] as String,
      map['usage'] as int,
      map['fileCount'] as int,
      map['sharedCollectionsCount'] as int,
      Subscription.fromMap(map['subscription']),
      FamilyData.fromMap(map['familyData']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'usage': usage,
      'fileCount': fileCount,
      'sharedCollectionsCount': sharedCollectionsCount,
      'subscription': subscription,
      'familyData': familyData
    };
  }
}

class FamilyMember {
  final String email;
  final int usage;
  final String id;
  final bool isAdmin;

  FamilyMember(this.email, this.usage, this.id, this.isAdmin);

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      (map['email'] ?? '') as String,
      map['usage'] as int,
      map['id'] as String,
      map['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'usage': usage, 'id': id, 'isAdmin': isAdmin};
  }
}

class FamilyData {
  final List<FamilyMember> members;

  // Storage available based on the family plan
  final int storage;
  final int expiryTime;

  FamilyData(this.members, this.storage, this.expiryTime);

  int getTotalUsage() {
    return members.map((e) => e.usage).toList().sum;
  }

  factory FamilyData.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }
    assert(map['members'] != null && map['members'].length >= 0);
    final members = List<FamilyMember>.from(
        map['members'].map((x) => FamilyMember.fromMap(x)));
    return FamilyData(
      members,
      map['storage'] as int,
      map['expiryTime'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members.map((x) => x?.toMap())?.toList(),
      'storage': storage,
      'expiryTime': expiryTime
    };
  }
}
