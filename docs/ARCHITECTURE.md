# Architecture

## Overview

Fashion POS Enterprise follows **Feature-First Clean Architecture** with clear separation of concerns, designed for a 10-year maintenance horizon and multi-tenant SaaS scale.

## Layer Responsibilities

### App Layer (lib/app/)
Application shell: bootstrap, routing, theme, localization, root providers.

### Core Layer (lib/core/)
Framework-agnostic utilities: config, errors, logging, services, network, sync.

### Design System (lib/design_system/)
UI foundation: colors, typography, spacing, breakpoints, components, state widgets.

### Features Layer (lib/features/)
Self-contained feature modules with data/domain/presentation layers.

## State Management
Riverpod: Provider, NotifierProvider, StreamProvider, FutureProvider.

## Navigation
GoRouter with named routes, path constants, custom transitions.

## Backend
Supabase: Auth, PostgreSQL, Realtime, Storage.

## Dependency Flow
Presentation -> Domain <- Data
All layers depend on Core and Design System.

## Error Handling
Exception (Data) -> ErrorHandler -> Failure (Domain) -> UI State Widget

## Security
- Never expose service_role key in client
- RLS on all Supabase tables
- app_metadata for authorization
