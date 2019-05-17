class MangaStatus {

  String label;

  MangaStatus(String label) {
    this.label = label;
  }

  static final MangaStatus UNKNOWN = MangaStatus('Unknown');
  static final MangaStatus ONGOING = MangaStatus('Ongoing');
  static final MangaStatus COMPLETE = MangaStatus('Complete');

  static MangaStatus fromString(label) {
    if (label == ONGOING.label) {
      return ONGOING;
    } else if (label == COMPLETE.label) {
      return COMPLETE;
    } else {
      return UNKNOWN;
    }
  }
}