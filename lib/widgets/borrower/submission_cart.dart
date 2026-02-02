import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/themed_date_picker.dart';
import 'package:lendo/providers/borrower/borrower.dart';
import 'package:lendo/services/auth_service.dart';

class SubmissionCart extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>)? onRemoveItem;
  final Function(Map<String, dynamic>, int)? onUpdateQuantity;

  const SubmissionCart({
    super.key,
    required this.cartItems,
    this.onRemoveItem,
    this.onUpdateQuantity,
  });

  @override
  ConsumerState<SubmissionCart> createState() => _SubmissionCartState();
}

class _SubmissionCartState extends ConsumerState<SubmissionCart> {
  DateTime? pickupDate;
  DateTime? returnDate;
  String reason = '';

  late final authService;
  var currentUser;

  @override
  void initState() {
    super.initState();
    authService = ref.read(authServicePod);
    currentUser = authService.getCurrentUser();
    print('Current User ID: ${currentUser?.id}');
  }

  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final DateTime? picked = await ThemedDatePicker.showThemedDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          pickupDate = picked;
          if (returnDate == null || returnDate!.isBefore(picked)) {
            returnDate = picked.add(const Duration(days: 1));
          }
        } else {
          if (pickupDate != null && picked.isBefore(pickupDate!)) {
            returnDate = pickupDate!.add(const Duration(days: 1));
          } else {
            returnDate = picked;
          }
        }
      });
    }
  }

  void _updateReason(String value) {
    setState(() {
      reason = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DateAndReasonFields(
          pickupDate: pickupDate,
          returnDate: returnDate,
          reason: reason,
          onDateSelected: _selectDate,
          onReasonChanged: _updateReason,
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.cartItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = widget.cartItems[index];
            return _CartItemTile(
              item: item,
              onRemoveItem: widget.onRemoveItem,
              onUpdateQuantity: widget.onUpdateQuantity,
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _SubmitButton(
          onPressed: () async {
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User belum login!')),
              );
              return;
            }

            final loanService = ref.read(loanServiceProvider);

            try {
              await loanService.addLoan(
                userId: currentUser.id,
                loanDate: pickupDate!,
                dueDate: returnDate!,
                reason: reason,
                assetIds:
                    widget.cartItems.map((e) => e['id'] as int).toList(),
              );

              setState(() {
                widget.cartItems.clear();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Peminjaman berhasil!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(content: Text('Gagal: ${e.toString()}')),
              );
            }
          },
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>)? onRemoveItem;
  final Function(Map<String, dynamic>, int)? onUpdateQuantity;

  const _CartItemTile({
    required this.item,
    this.onRemoveItem,
    this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  int currentQty = item['quantity'] as int;
                  if (currentQty > 1) {
                    onUpdateQuantity?.call(item, currentQty - 1);
                  } else {
                    onRemoveItem?.call(item);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
              ),
              Text(
                '${item['quantity']}',
                style: TextStyle(color: AppColors.gray),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  int currentQty = item['quantity'] as int;
                  int stock = item['stock'] as int;
                  if (currentQty < stock) {
                    onUpdateQuantity?.call(item, currentQty + 1);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 16),
                onPressed: () {
                  onRemoveItem?.call(item);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SubmitButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Submit', style: TextStyle(color: AppColors.white)),
      ),
    );
  }
}

class _DateAndReasonFields extends StatefulWidget {
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final String reason;
  final Function(BuildContext, bool) onDateSelected;
  final Function(String) onReasonChanged;

  const _DateAndReasonFields({
    Key? key,
    required this.pickupDate,
    required this.returnDate,
    required this.reason,
    required this.onDateSelected,
    required this.onReasonChanged,
  }) : super(key: key);

  @override
  _DateAndReasonFieldsState createState() => _DateAndReasonFieldsState();
}

class _DateAndReasonFieldsState extends State<_DateAndReasonFields> {
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.reason);
    _reasonController.addListener(() {
      widget.onReasonChanged(_reasonController.text);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateField(
            label: 'Tanggal Pengambilan',
            date: widget.pickupDate,
            onTap: () => widget.onDateSelected(context, true),
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'Tanggal Pengembalian',
            date: widget.returnDate,
            onTap: () => widget.onDateSelected(context, false),
          ),
          const SizedBox(height: 12),
          Text('Alasan', style: TextStyle(color: AppColors.gray, fontSize: 14)),
          const SizedBox(height: 4),
          TextField(
            style: TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Masukkan alasan peminjaman',
              hintStyle: TextStyle(color: AppColors.gray.withOpacity(0.6)),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            maxLines: 3,
            controller: _reasonController,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.gray, fontSize: 14)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              style: TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Pilih tanggal',
                hintStyle: TextStyle(color: AppColors.gray.withOpacity(0.6)),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 16),
              ),
              controller: TextEditingController(
                text: date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : '',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
