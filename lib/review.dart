import 'dart:async';

import 'package:two_finance_blockchain/blockchain/contract/reviewV1.dart' as reviewV1;
import 'package:two_finance_blockchain/blockchain/keys.dart' as keys;
import 'package:two_finance_blockchain/blockchain/types.dart';

class Review {
  final String publicKey;

  Review({required this.publicKey});

  /// Mock dos métodos sendTransaction e getState
  /// Substitua com sua implementação real
  Future<ContractOutput> sendTransaction(
      String from,
      String to,
      String contractVersion,
      String method,
      Map<String, dynamic> data) async {
    // Implementação real aqui
    return ContractOutput();
  }

  Future<ContractOutput> getState(
      String contractVersion,
      String method,
      Map<String, dynamic> data) async {
    // Implementação real aqui
    return ContractOutput();
  }

  Future<ContractOutput> addReview({
    String? address,
    required String reviewer,
    required String reviewee,
    required String subjectType,
    required String subjectID,
    required int rating,
    required String comment,
    Map<String, String>? tags,
    List<String>? mediaHashes,
    required DateTime startAt,
    required DateTime expiredAt,
    required bool hidden,
  }) async {
    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    // Generate new address if null
    if (address == null || address.isEmpty) {
      final pub = await keys.generateKeyEd25519(); // Deve retornar apenas a chave pública
      address = pub;
    }
    keys.validateEDDSAPublicKey(address);

    if (reviewer.isEmpty) throw Exception("reviewer not set");
    keys.validateEDDSAPublicKey(reviewer);

    if (reviewee.isEmpty) throw Exception("reviewee not set");
    keys.validateEDDSAPublicKey(reviewee);

    if (subjectType.isEmpty) throw Exception("subject_type not set");
    if (subjectID.isEmpty) throw Exception("subject_id not set");
    if (rating < 1 || rating > 5) throw Exception("rating must be between 1 and 5");
    if (startAt == DateTime(0)) throw Exception("start_at not set");
    if (expiredAt == DateTime(0)) throw Exception("expired_at not set");

    final to = types.DEPLOY_CONTRACT_ADDRESS;
    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_ADD_REVIEW;

    final data = {
      "address": address,
      "comment": comment,
      "expired_at": expiredAt.toIso8601String(),
      "hidden": hidden,
      "media_hashes": mediaHashes ?? [],
      "rating": rating,
      "reviewee": reviewee,
      "reviewer": reviewer,
      "start_at": startAt.toIso8601String(),
      "subject_id": subjectID,
      "subject_type": subjectType,
      "tags": tags ?? {},
    };

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> updateReview({
    required String address,
    required String subjectType,
    required String subjectID,
    int rating = 0,
    String? comment,
    Map<String, String>? tags,
    List<String>? mediaHashes,
    DateTime? startAt,
    DateTime? expiredAt,
  }) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    if (subjectType.isEmpty) throw Exception("subject_type not set");
    if (subjectID.isEmpty) throw Exception("subject_id not set");
    if (rating != 0 && (rating < 1 || rating > 5)) {
      throw Exception("rating must be between 1 and 5");
    }

    final to = address;
    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_UPDATE_REVIEW;

    final data = {
      "address": address,
      "comment": comment ?? '',
      "media_hashes": mediaHashes ?? [],
      "rating": rating,
      "subject_id": subjectID,
      "subject_type": subjectType,
      "tags": tags ?? {},
    };
    if (startAt != null) data["start_at"] = startAt.toIso8601String();
    if (expiredAt != null) data["expired_at"] = expiredAt.toIso8601String();

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> hideReview(String address, bool hidden) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_HIDE_REVIEW;
    final data = {"address": address, "hidden": hidden};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> voteHelpful(String address, String voter, bool isHelpful) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);
    if (voter.isEmpty) throw Exception("voter not set");
    keys.validateEDDSAPublicKey(voter);

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_VOTE_HELPFUL;
    final data = {"address": address, "voter": voter, "is_helpful": isHelpful};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> reportReview(String address, String reporter, String reason) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);
    if (reporter.isEmpty) throw Exception("reporter not set");
    keys.validateEDDSAPublicKey(reporter);
    if (reason.isEmpty) throw Exception("reason not set");

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_REPORT_REVIEW;
    final data = {"address": address, "reporter": reporter, "reason": reason};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> moderateReview(String address, String action, String note) async {
    if (address.isEmpty) throw Exception("address not set");
    keys.validateEDDSAPublicKey(address);
    if (action.isEmpty) throw Exception("action not set");

    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    final to = address;
    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_MODERATE_REVIEW;
    final data = {"address": address, "action": action, "note": note};

    return sendTransaction(from, to, contractVersion, method, data);
  }

  Future<ContractOutput> getReview(String address) async {
    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    if (address.isEmpty) throw Exception("review address must be set");
    keys.validateEDDSAPublicKey(address);

    final contractVersion = reviewV1.REVIEW_CONTRACT_V1;
    final method = reviewV1.METHOD_GET_REVIEW;
    final data = {"address": address};

    return getState(contractVersion, method, data);
  }

  Future<ContractOutput> listReviews({
    String? owner,
    String? reviewer,
    String? reviewee,
    String? subjectType,
    String? subjectID,
    bool? includeHidden,
    int minRating = 0,
    int maxRating = 5,
    required int page,
    required int limit,
    required bool asc,
  }) async {
    final from = publicKey;
    if (from.isEmpty) throw Exception("from address not set");
    keys.validateEDDSAPublicKey(from);

    if (owner != null && owner.isNotEmpty) keys.validateEDDSAPublicKey(owner);
    if (reviewer != null && reviewer.isNotEmpty) keys.validateEDDSAPublicKey(reviewer);
    if (reviewee != null && reviewee.isNotEmpty) keys.validateEDDSAPublicKey(reviewee);

    if (page < 1) throw Exception("page must be greater than 0");
    if (limit < 1) throw Exception("limit must be greater than 0");
    if (minRating < 0 || minRating > 5) throw Exception("min_rating must be between 0 and 5");
    if (maxRating < 0 || maxRating > 5) throw Exception("max_rating must be between 0 and 5");
    if (maxRating != 0 && minRating > maxRating) throw Exception("min_rating cannot be greater than max_rating
