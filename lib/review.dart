part of 'two_finance_blockchain.dart';
extension Review on TwoFinanceBlockchain{
 
  /// Mock dos métodos sendTransaction e getState
  /// Substitua com sua implementação real

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
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);

    // Generate new address if null
    if (address == null || address.isEmpty) {
      final pub = await generateKeyEd25519().toString(); // Deve retornar apenas a chave pública
      address = pub;
    }
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address ?? "");

    if (reviewer.isEmpty) throw Exception("reviewer not set");
    //keys.validateEDDSAPublicKey(reviewer);
    KeyManager.validateEdDSAPublicKey(reviewer);

    if (reviewee.isEmpty) throw Exception("reviewee not set");
    //keys.validateEDDSAPublicKey(reviewee);
    KeyManager.validateEdDSAPublicKey(reviewer);

    if (subjectType.isEmpty) throw Exception("subject_type not set");
    if (subjectID.isEmpty) throw Exception("subject_id not set");
    if (rating < 1 || rating > 5) throw Exception("rating must be between 1 and 5");
    if (startAt == DateTime(0)) throw Exception("start_at not set");
    if (expiredAt == DateTime(0)) throw Exception("expired_at not set");

    final to = types.DEPLOY_CONTRACT_ADDRESS;
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_ADD_REVIEW;

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

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
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
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);

    if (subjectType.isEmpty) throw Exception("subject_type not set");
    if (subjectID.isEmpty) throw Exception("subject_id not set");
    if (rating != 0 && (rating < 1 || rating > 5)) {
      throw Exception("rating must be between 1 and 5");
    }

    final to = address;
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_UPDATE_REVIEW;

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

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> hideReview(String address, bool hidden) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);

    final to = address;
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_HIDE_REVIEW;
    final data = {"address": address, "hidden": hidden};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> voteHelpful(String address, String voter, bool isHelpful) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    if (voter.isEmpty) throw Exception("voter not set");
    //keys.validateEDDSAPublicKey(voter);
    KeyManager.validateEdDSAPublicKey(voter);

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);

    final to = address;
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_VOTE_HELPFUL;
    final data = {"address": address, "voter": voter, "is_helpful": isHelpful};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> reportReview(String address, String reporter, String reason) async {
    if (address.isEmpty) throw Exception("address not set");
    KeyManager.validateEdDSAPublicKey(address);
    //keys.validateEDDSAPublicKey(address);
    if (reporter.isEmpty) throw Exception("reporter not set");
    KeyManager.validateEdDSAPublicKey(reporter);
    //keys.validateEDDSAPublicKey(reporter);
    if (reason.isEmpty) throw Exception("reason not set");

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);
    final to = address;
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_REPORT_REVIEW;
    final data = {"address": address, "reporter": reporter, "reason": reason};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> moderateReview(String address, String action, String note) async {
    if (address.isEmpty) throw Exception("address not set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    if (action.isEmpty) throw Exception("action not set");

    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);

    final to = address;
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_MODERATE_REVIEW;
    final data = {"address": address, "action": action, "note": note};

    return signAndSendTransaction(from: from, to: to, contractVersion: contractVersion, method: method, data: data);
  }

  Future<ContractOutput> getReview(String address) async {
    final from = _activePublicKey!;
    if (from.isEmpty) throw Exception("from address not set");
    //keys.validateEDDSAPublicKey(from);
    KeyManager.validateEdDSAPublicKey(from);
    if (address.isEmpty) throw Exception("review address must be set");
    //keys.validateEDDSAPublicKey(address);
    KeyManager.validateEdDSAPublicKey(address);
    final contractVersion = REVIEW_CONTRACT_V1;
    final method = METHOD_GET_REVIEW;
    final data = {"address": address};

    return getState(contractVersion: contractVersion, method: method, data: data);
  }

Future<ContractOutput> listReviews({
  String owner = '',
  String reviewer = '',
  String reviewee = '',
  String subjectType = '',
  String subjectId = '',
  bool? includeHidden,
  int minRating = 0,
  int maxRating = 0,
  int page = 1,
  int limit = 10,
  bool asc = true,
}) async {
  final from = _activePublicKey!;
  if (from.isEmpty) {
    throw Exception('from address not set');
  }

  KeyManager.validateEdDSAPublicKey(from);

  // Validações opcionais
  if (owner.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(owner);
  }
  if (reviewer.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(reviewer);
  }
  if (reviewee.isNotEmpty) {
    KeyManager.validateEdDSAPublicKey(reviewee);
  }

  if (page < 1) throw Exception('page must be greater than 0');
  if (limit < 1) throw Exception('limit must be greater than 0');
  if (minRating < 0 || minRating > 5) {
    throw Exception('min_rating must be between 0 and 5');
  }
  if (maxRating < 0 || maxRating > 5) {
    throw Exception('max_rating must be between 0 and 5');
  }
  if (maxRating != 0 && minRating > maxRating) {
    throw Exception('min_rating cannot be greater than max_rating');
  }

  const contractVersion = REVIEW_CONTRACT_V1;
  const method = METHOD_LIST_REVIEWS;

  final data = <String, dynamic>{
    "reviewer": reviewer,
    "reviewee": reviewee,
    "subject_id": subjectId,
    "subject_type": subjectType,
    "min_rating": minRating,
    "max_rating": maxRating,
    "page": page,
    "limit": limit,
    "ascending": asc,
  };

  if (includeHidden != null) {
    data["include_hidden"] = includeHidden;
  }

  return await getState(contractVersion: contractVersion, method: method, data: data);
}

}