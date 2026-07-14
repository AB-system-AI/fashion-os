# Naming Conventions

## Folders
- snake_case: product_catalog, point_of_sale
- Plural for collections: entities, models, usecases, providers

## Files
- snake_case.dart: product_repository.dart
- Suffix by type:
  - _page.dart, _widget.dart, _provider.dart
  - _repository.dart, _repository_impl.dart
  - _datasource.dart, _model.dart, _entity.dart
  - _usecase.dart or verb_noun.dart: get_products.dart

## Classes
- PascalCase: ProductRepository, GetProducts
- Pages: ProductListPage
- Widgets: ProductCard
- Providers: productListProvider
- Use Cases: GetProducts, CreateOrder

## Variables
- camelCase: productList, isLoading
- Private: _repository
- Booleans: is/has/can/should prefix

## Constants
- lowerCamelCase in abstract final classes
- static const in dedicated constants files

## Routes
- Paths: /products, /products/:id
- Names: products, productDetail
