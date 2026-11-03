enum OfflineSyncPhase {
  ready,
  syncing,
  offline,
  authenticationRequired,
  conflict,
  storageError,
}

class OfflineIdentity {
  const OfflineIdentity({
    required this.scope,
    required this.ownerId,
    required this.userId,
  });
  final String scope, ownerId, userId;
}

class OfflineSyncState {
  const OfflineSyncState({
    this.phase = OfflineSyncPhase.ready,
    this.pending = 0,
    this.revision = 0,
  });
  final OfflineSyncPhase phase;
  final int pending;
  final int revision;
}
