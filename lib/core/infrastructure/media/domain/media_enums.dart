/// Media owner entity categories.
enum MediaCategory {
  product,
  category,
  brand,
  customer,
  employee,
  supplier,
  store,
  logo,
  receipt,
  invoice,
  attachment,
  excel,
  csv,
  pdf,
  backup,
  barcode,
  qr,
  video,
}

/// Image output format.
enum ImageFormat {
  jpeg,
  png,
  webp,
  svg,
  avif,
}

/// Image processing operations.
enum ImageOperation {
  resize,
  compress,
  thumbnail,
  crop,
  rotate,
  autoOrient,
  convert,
}

/// Media variant (original, thumbnail, etc.).
enum MediaVariant {
  original,
  thumbnail,
  medium,
  large,
  preview,
}

/// Local cache tier.
enum CacheTier {
  memory,
  disk,
  persistent,
  temporary,
}

/// Remote storage backend identifier.
enum StorageBackend {
  local,
  supabase,
  s3,
  cloudflareR2,
  googleCloudStorage,
  azureBlob,
  custom,
}

/// Upload job lifecycle status.
enum UploadStatus {
  queued,
  processing,
  paused,
  uploading,
  completed,
  failed,
  cancelled,
}

/// Download job lifecycle status.
enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Media sync status for offline queue.
enum MediaSyncStatus {
  localOnly,
  pendingUpload,
  uploading,
  synced,
  conflict,
  failed,
}

/// Document type handled by document engine.
enum DocumentType {
  pdf,
  excel,
  csv,
  text,
  backupArchive,
  docx,
}

/// Network-aware upload quality profile.
enum UploadQualityProfile {
  low,
  standard,
  high,
  original,
}

/// Access policy for signed URLs.
enum MediaAccessPolicy {
  publicRead,
  authenticatedRead,
  tenantScoped,
  ownerOnly,
}
