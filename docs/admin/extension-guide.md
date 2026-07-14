# Extension Guide

## Add an org entity

1. Add entity in `domain/entities/organization.dart` (or new file)
2. Add repository abstract + `*LocalRepository` in data layer
3. Register provider + sync processor in `admin_providers.dart`
4. Register processor in `admin_module_initializer.dart`
5. Add Supabase table + RLS in a new migration
6. Add route path, page, and dashboard tile

## Add a settings section

Extend `TenantSettings.values` JSON schema and add a page under `/admin/*-settings`.

## Engine rules

Add pure validation to `AdministrationEngine` in `lib/core/business/engines/admin/`.
