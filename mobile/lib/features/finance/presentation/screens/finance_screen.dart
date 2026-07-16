import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/features/hub/data/models/hub_models.dart';
import 'package:taskmail/features/hub/presentation/providers/hub_providers.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/shared/widgets/daos_page_scaffold.dart';
import 'package:taskmail/shared/widgets/hub_menu_card.dart';
import 'package:taskmail/shared/widgets/loading_error_widgets.dart';
import 'package:taskmail/theme/app_colors.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _selectedType = 'home';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;
    final financeAsync = ref.watch(financeProvider(_selectedType));

    return DaosPageScaffold(
      title: l.financeTitle,
      searchHint: l.searchBar,
      showSearch: false,
      avatarInitial: user?.name ?? user?.email,
      avatarUrl: user?.avatarUrl,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: financeAsync.when(
        loading: () => const ShimmerLoading(itemCount: 4),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(financeProvider(_selectedType)),
        ),
        data: (finance) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(financeProvider(_selectedType)),
          color: AppColors.primary,
          backgroundColor: AppColors.darkSurface,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            children: [
              _BudgetTypeToggle(
                selected: _selectedType,
                homeLabel: l.budgetHome,
                businessLabel: l.budgetBusiness,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 12),
              Text(
                finance.monthLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _MonthlyBudgetCard(summary: finance.summary, l: l),
              const SizedBox(height: 12),
              _SavingsCard(summary: finance.summary, l: l),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_back, color: AppColors.success, size: 18),
                              const SizedBox(width: 6),
                              Text(l.incomeLabel, style: const TextStyle(color: AppColors.darkTextSecondary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatIls(finance.summary.income),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_forward, color: AppColors.critical, size: 18),
                              const SizedBox(width: 6),
                              Text(l.expensesLabel, style: const TextStyle(color: AppColors.darkTextSecondary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatIls(-finance.summary.expenses.abs()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.critical,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  children: [
                    Text(l.totalBalance, style: const TextStyle(color: AppColors.darkTextSecondary)),
                    const Spacer(),
                    Text(
                      formatIls(finance.summary.balance),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.recentTransactions,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (finance.transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l.noTransactions,
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                )
              else
                ...finance.transactions.map(
                  (tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(hubIconForKey(tx.icon), color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                                Text(
                                  tx.time,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatIls(tx.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: tx.amount >= 0 ? AppColors.success : AppColors.critical,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddTransactionSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    var txType = 'expense';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l.addTransaction, style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l.transactionExpense),
                        selected: txType == 'expense',
                        onSelected: (_) => setSheetState(() => txType = 'expense'),
                      ),
                      ChoiceChip(
                        label: Text(l.transactionIncome),
                        selected: txType == 'income',
                        onSelected: (_) => setSheetState(() => txType = 'income'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: l.transactionTitle),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l.transactionAmount),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l.apply),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved != true || !mounted) return;

    final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
    final title = titleController.text.trim();
    if (amount == null || amount <= 0 || title.isEmpty) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.invalidTransaction)));
      return;
    }

    try {
      await ref.read(hubRemoteDataSourceProvider).createFinanceTransaction(
            budgetType: _selectedType,
            title: title,
            amount: amount,
            txType: txType,
          );
      ref.invalidate(financeProvider(_selectedType));
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.transactionAdded)));
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.serverError)));
    }
  }
}

class _BudgetTypeToggle extends StatelessWidget {
  const _BudgetTypeToggle({
    required this.selected,
    required this.homeLabel,
    required this.businessLabel,
    required this.onChanged,
  });

  final String selected;
  final String homeLabel;
  final String businessLabel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: homeLabel,
              selected: selected == 'home',
              onTap: () => onChanged('home'),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: businessLabel,
              selected: selected == 'business',
              onTap: () => onChanged('business'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyBudgetCard extends StatelessWidget {
  const _MonthlyBudgetCard({required this.summary, required this.l});

  final BudgetSummaryData summary;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final spentRatio = summary.expenseBudget > 0
        ? (summary.expenses / summary.expenseBudget).clamp(0.0, 1.0)
        : 0.0;
    final barColor = spentRatio > 0.9
        ? AppColors.critical
        : spentRatio > 0.7
            ? AppColors.warning
            : AppColors.primary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.monthlyBudget, style: const TextStyle(color: AppColors.darkTextSecondary)),
          const SizedBox(height: 8),
          Text(
            l.budgetSpentSummary(summary.expenses, summary.expenseBudget),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: spentRatio,
              minHeight: 8,
              backgroundColor: AppColors.darkGlassBorder,
              color: barColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.budgetRemainingLabel(summary.budgetRemaining),
            style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.summary, required this.l});

  final BudgetSummaryData summary;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final ratio = (summary.savingsProgress / 100).clamp(0.0, 1.0);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_outlined, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              Text(l.savingsGoal, style: const TextStyle(color: AppColors.darkTextSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.savingsProgressSummary(summary.savingsSaved, summary.savingsTarget),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.darkGlassBorder,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${summary.savingsProgress.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
