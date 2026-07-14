import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/barcode_abstraction.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_abstraction.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/printer_hub_impl.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product_variant.dart';

enum BarcodeLabelLayout { standard, compact, qr }

/// Barcode label generation and printing via printer abstraction only.
class BarcodeLabelPrintService {
  BarcodeLabelPrintService({
    required BarcodeEngine barcodeEngine,
    required PrinterHubImpl printerHub,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
  })  : _barcode = barcodeEngine,
        _printer = printerHub,
        _audit = auditService,
        _permissions = permissionEngine;

  final BarcodeEngine _barcode;
  final PrinterHubImpl _printer;
  final AuditService _audit;
  final PermissionEngine _permissions;

  Future<Result<String>> generateBarcodeValue({
    BarcodeFormat format = BarcodeFormat.ean13,
    String? seed,
  }) async {
    final value = seed ?? DateTime.now().millisecondsSinceEpoch.toString().padLeft(12, '0').substring(0, 12);
    return _barcode.generate(format: format, value: value).map((p) => p.value);
  }

  Future<Result<List<int>>> previewLabel({
    required AuthUser user,
    required Product product,
    ProductVariant? variant,
    BarcodeLabelLayout layout = BarcodeLabelLayout.standard,
    String format = 'code128',
  }) async {
    try {
      _permissions.require(user, ProductPermissions.read);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final request = _buildRequest(product: product, variant: variant, layout: layout, format: format);
    try {
      final bytes = await _printer.previewLabelImage(request);
      await _audit.log(
        action: AuditAction.export,
        entityType: Product.entityTypeName,
        tenantId: user.tenantId,
        employeeId: user.employeeId,
        entityId: product.id,
        metadata: {'change_type': 'barcode_generate', 'layout': layout.name, 'format': format},
      );
      return Success(bytes);
    } catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'preview_failed'));
    }
  }

  Future<Result<List<int>>> printLabels({
    required AuthUser user,
    required Product product,
    List<ProductVariant>? variants,
    BarcodeLabelLayout layout = BarcodeLabelLayout.standard,
    String format = 'code128',
    int copiesPerLabel = 1,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.export);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final requests = <BarcodeLabelRequest>[];
    if (variants != null && variants.isNotEmpty) {
      for (final variant in variants) {
        requests.add(
          _buildRequest(product: product, variant: variant, layout: layout, format: format, copies: copiesPerLabel),
        );
      }
    } else {
      requests.add(_buildRequest(product: product, layout: layout, format: format, copies: copiesPerLabel));
    }

    try {
      await _printer.connect(
        (await _printer.discoverAll()).firstWhere((d) => d.connectionType == PrinterConnectionType.pdf),
      );
      final pdf = await _printer.printLabelBatch(requests);
      await _audit.log(
        action: AuditAction.export,
        entityType: Product.entityTypeName,
        tenantId: user.tenantId,
        employeeId: user.employeeId,
        entityId: product.id,
        metadata: {'change_type': 'barcode_print', 'count': requests.length, 'layout': layout.name},
      );
      return Success(pdf);
    } catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'print_failed'));
    }
  }

  BarcodeLabelRequest _buildRequest({
    required Product product,
    ProductVariant? variant,
    BarcodeLabelLayout layout = BarcodeLabelLayout.standard,
    String format = 'code128',
    int copies = 1,
  }) {
    final barcode = variant?.barcode ?? product.barcode ?? product.sku;
    final name = variant != null ? '${product.name} (${variant.color ?? variant.size ?? variant.sku})' : product.name;
    final price = variant?.retailPriceOverride ?? product.retailPrice;
    return BarcodeLabelRequest(
      value: barcode,
      productName: name,
      format: layout == BarcodeLabelLayout.qr ? 'qr' : format,
      price: price,
      sku: variant?.sku ?? product.sku,
      copies: copies,
    );
  }
}
