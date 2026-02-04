import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';

class ReturnCard extends StatefulWidget {
  final Map<String, dynamic> loan;
  final Function(Map<String, dynamic>, Map<String, String>, String)
  onConfirmReturn;

  const ReturnCard({
    Key? key,
    required this.loan,
    required this.onConfirmReturn,
  }) : super(key: key);

  @override
  State<ReturnCard> createState() => _ReturnCardState();
}

class _ReturnCardState extends State<ReturnCard> {
  final Map<String, String> _returnConditions = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan #${widget.loan['id']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${widget.loan['loanDate']}',
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.undo, color: AppColors.white),
                onPressed: () => _showReturnForm(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReturnForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
            ),
            child: _buildReturnForm(),
          ),
        );
      },
    );
  }

  Widget _buildReturnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Return Loan #${widget.loan['id']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Set return condition for each asset:',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView(
            children: [
              ...widget.loan['assets'].map<Widget>((asset) {
                String key = '${widget.loan['id']}_${asset['id']}';
                String currentCondition = _returnConditions[key] ?? 'good';

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset['name'],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Borrowed Condition: ${asset['condition_borrow']}',
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Return Condition:',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      DropdownButtonFormField<String>(
                        value: _mapToDropdownValue(currentCondition),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.secondary,
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
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: AppColors.white),
                        dropdownColor: AppColors.secondary,
                        items: [
                          DropdownMenuItem(
                            value: 'ringan',
                            child: Text(
                              'Ringan',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'sedang',
                            child: Text(
                              'Sedang',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'parah',
                            child: Text(
                              'Parah',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _returnConditions[key] = _mapFromDropdownValue(
                                newValue,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Reason for return:',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          style: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Enter reason for returning these items...',
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
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: ElevatedButton(
            onPressed: () => _confirmReturn(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Return',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  String _mapToDropdownValue(String value) {
    if (value == 'good' || value == 'ringan') return 'ringan';
    if (value == 'minor' || value == 'sedang') return 'sedang';
    if (value == 'major' || value == 'parah' || value == 'damaged')
      return 'parah';
    return 'ringan';
  }

  String _mapFromDropdownValue(String value) {
    if (value == 'ringan') return 'good';
    if (value == 'sedang') return 'minor';
    if (value == 'parah') return 'major';
    return 'good';
  }

  void _confirmReturn() {
    Navigator.pop(context);
  }
}
