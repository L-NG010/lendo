import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/submission_cart.dart';
import 'package:lendo/providers/borrower/asset.dart';

class BorrowerSubmissionScreen extends ConsumerStatefulWidget {
  const BorrowerSubmissionScreen({super.key});

  @override
  ConsumerState<BorrowerSubmissionScreen> createState() =>
      _BorrowerSubmissionScreenState();
}

class _BorrowerSubmissionScreenState
    extends ConsumerState<BorrowerSubmissionScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  bool _isCartVisible = false;

  int _getItemQuantity(String assetName) {
    var item = _cartItems.firstWhere(
      (item) => item['name'] == assetName,
      orElse: () => {'quantity': 0},
    );
    return (item['quantity'] ?? 0) as int;
  }

  bool _isItemInCart(String assetName) {
    return _cartItems.any((item) => item['name'] == assetName);
  }

  int get _totalCartItems {
    return _cartItems.fold(
      0,
      (sum, item) => sum + ((item['quantity'] ?? 0) as int),
    );
  }

  @override
  void initState() {
    super.initState();
    // Refresh asset stock data every time screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(assetStockProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Submission',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.white,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCartVisible = !_isCartVisible;
                      });
                    },
                  ),
                  if (_totalCartItems > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$_totalCartItems',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Expanded(
                  child: ref
                      .watch(assetStockProvider)
                      .when(
                        data: (assetStocks) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(assetStockProvider);
                              await ref.read(assetStockProvider.future);
                            },
                            child: ListView.builder(
                              itemCount: assetStocks.length,
                              itemBuilder: (context, index) {
                                final asset = assetStocks[index];
                                final isInCart = _isItemInCart(asset.name);
                                final quantity = _getItemQuantity(asset.name);
                                final isStockExhausted =
                                    quantity >= asset.available;
                                final isNotAvailable = asset.available <= 0;

                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isNotAvailable
                                          ? AppColors.gray.withValues(
                                              alpha: 0.3,
                                            )
                                          : isInCart
                                          ? AppColors.primary
                                          : AppColors.outline,
                                      width: isNotAvailable
                                          ? 1
                                          : (isInCart ? 2 : 1),
                                    ),
                                  ),
                                  child: Opacity(
                                    opacity: isNotAvailable ? 0.6 : 1.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: asset.pictureUrl != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                        asset.pictureUrl!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: asset.pictureUrl == null
                                                ? Icon(
                                                    Icons.image,
                                                    size: 16,
                                                    color: AppColors.gray,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  asset.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    if (isNotAvailable)
                                                      Icon(
                                                        Icons.info_outline,
                                                        size: 14,
                                                        color: AppColors.gray,
                                                      ),
                                                    if (isNotAvailable)
                                                      const SizedBox(width: 4),
                                                    Text(
                                                      isNotAvailable
                                                          ? 'Unavailable'
                                                          : 'Stock: ${asset.available}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.gray,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Stack(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_shopping_cart,
                                                  color:
                                                      isNotAvailable ||
                                                          isStockExhausted
                                                      ? AppColors.gray
                                                            .withValues(
                                                              alpha: 0.5,
                                                            )
                                                      : AppColors.gray,
                                                  size: 20,
                                                ),
                                                onPressed:
                                                    isNotAvailable ||
                                                        isStockExhausted
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var existingItemIndex =
                                                              _cartItems.indexWhere(
                                                                (item) =>
                                                                    item['name'] ==
                                                                    asset.name,
                                                              );

                                                          if (existingItemIndex !=
                                                              -1) {
                                                            int
                                                            currentQuantity =
                                                                _cartItems[existingItemIndex]['quantity']
                                                                    as int;
                                                            if (currentQuantity <
                                                                asset
                                                                    .available) {
                                                              _cartItems[existingItemIndex]['quantity'] =
                                                                  currentQuantity +
                                                                  1;
                                                            }
                                                          } else {
                                                            _cartItems.add({
                                                              'name':
                                                                  asset.name,
                                                              'quantity': 1,
                                                              'stock': asset
                                                                  .available,
                                                            });
                                                          }
                                                        });
                                                      },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                              ),
                                              if (isInCart && quantity > 0)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 16,
                                                          minHeight: 16,
                                                        ),
                                                    child: Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            'Failed to load assets: $e',
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
        if (_isCartVisible) _buildCartOverlay(context),
      ],
    );
  }

  Widget _buildCartOverlay(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: _cartItems.isEmpty
                ? 250
                : MediaQuery.of(context).size.height * 0.75,
          ),
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.white),
                      onPressed: () {
                        setState(() {
                          _isCartVisible = false;
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: _cartItems.isEmpty
                      ? const _EmptyCart()
                      : Container(
                          constraints: BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            child: SubmissionCart(
                              cartItems: _cartItems,
                              onRemoveItem: (item) {
                                setState(() {
                                  _cartItems.removeWhere(
                                    (cartItem) =>
                                        cartItem['name'] == item['name'],
                                  );
                                });
                              },
                              onUpdateQuantity: (item, newQuantity) {
                                setState(() {
                                  final index = _cartItems.indexWhere(
                                    (cartItem) =>
                                        cartItem['name'] == item['name'],
                                  );
                                  if (index != -1) {
                                    _cartItems[index]['quantity'] = newQuantity;
                                  }
                                });
                              },
                              onSubmissionSuccess: () {
                                // Close cart and clear items
                                setState(() {
                                  _isCartVisible = false;
                                  _cartItems.clear();
                                });
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: TextStyle(fontSize: 16, color: AppColors.gray),
          ),
          const SizedBox(height: 8),
          Text(
            'Add assets to borrow',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
