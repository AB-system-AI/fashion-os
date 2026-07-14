/// Audit action types for enterprise compliance logging.
enum AuditAction {
  login,
  logout,
  sale,
  refund,
  returnItem,
  exchange,
  inventoryChange,
  priceChange,
  permissionChange,
  settingsChange,
  delete,
  create,
  update,
  export,
  importData,
  licenseCheck,
  sync,
}

extension AuditActionX on AuditAction {
  String get value => name;
}
