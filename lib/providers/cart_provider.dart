import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final int quantity;
  final int stock;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.stock,
  });

  CartItem copyWith({
    String? id,
    String? name,
    int? quantity,
    int? stock,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final bool isVisible;

  CartState({
    this.items = const [],
    this.isVisible = false,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isVisible,
  }) {
    return CartState(
      items: items ?? this.items,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => items.isEmpty;
}

// Using NotifierProvider with modern Riverpod syntax (flutter_riverpod 3.2.0+)
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void addItem(String id, String name, int stock) {
    final existingIndex = state.items.indexWhere((item) => item.id == id);
    
    if (existingIndex != -1) {
      // Item already exists, increase quantity if not exceeding stock
      final currentItem = state.items[existingIndex];
      if (currentItem.quantity < currentItem.stock) {
        final updatedItems = [...state.items];
        updatedItems[existingIndex] = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
        );
        state = state.copyWith(items: updatedItems);
      }
    } else {
      // Add new item
      final newItem = CartItem(
        id: id,
        name: name,
        quantity: 1,
        stock: stock,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void removeItem(String id) {
    final updatedItems = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updatedItems);
  }

  void updateQuantity(String id, int newQuantity) {
    final existingIndex = state.items.indexWhere((item) => item.id == id);
    
    if (existingIndex != -1) {
      final currentItem = state.items[existingIndex];
      if (newQuantity > 0 && newQuantity <= currentItem.stock) {
        final updatedItems = [...state.items];
        updatedItems[existingIndex] = currentItem.copyWith(quantity: newQuantity);
        state = state.copyWith(items: updatedItems);
      } else if (newQuantity <= 0) {
        removeItem(id);
      }
    }
  }

  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  void hide() {
    state = state.copyWith(isVisible: false);
  }

  void clear() {
    state = state.copyWith(items: []);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);