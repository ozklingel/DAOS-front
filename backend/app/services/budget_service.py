from datetime import UTC, date, datetime, time

from sqlalchemy.orm import Session

from app.core.security import new_id
from app.models import BudgetPlan, BudgetType, FinanceTransaction, TransactionType, User

HEBREW_MONTHS = [
    "ינואר",
    "פברואר",
    "מרץ",
    "אפריל",
    "מאי",
    "יוני",
    "יולי",
    "אוגוסט",
    "ספטמבר",
    "אוקטובר",
    "נובמבר",
    "דצמבר",
]

DEFAULT_PLANS = {
    BudgetType.home.value: {"expense_budget": 6000.0, "savings_target": 2000.0},
    BudgetType.business.value: {"expense_budget": 8000.0, "savings_target": 5000.0},
}


class BudgetService:
    def get_finance(self, db: Session, user: User, *, selected_type: str) -> dict:
        month = self._current_month()
        self._ensure_month_data(db, user, month)

        home = self._summary(db, user, BudgetType.home.value, month)
        business = self._summary(db, user, BudgetType.business.value, month)
        selected = home if selected_type == BudgetType.home.value else business
        transactions = self._list_transactions(db, user, selected_type, month)

        return {
            "currency": "ILS",
            "month": month,
            "month_label": self._month_label(month),
            "selected_type": selected_type,
            "home": home,
            "business": business,
            "summary": selected,
            "total_balance": home["balance"] + business["balance"],
            "income": selected["income"],
            "expenses": selected["expenses"],
            "transactions": transactions,
        }

    def create_transaction(
        self,
        db: Session,
        user: User,
        *,
        budget_type: str,
        title: str,
        amount: float,
        tx_type: str,
        category: str = "general",
        icon: str = "payment",
        occurred_at: datetime | None = None,
    ) -> FinanceTransaction:
        if budget_type not in {BudgetType.home.value, BudgetType.business.value}:
            raise ValueError("Invalid budget type")
        if tx_type not in {TransactionType.income.value, TransactionType.expense.value}:
            raise ValueError("Invalid transaction type")
        if amount <= 0:
            raise ValueError("Amount must be positive")

        month = self._current_month()
        self._ensure_plan(db, user.id, budget_type, month)

        tx = FinanceTransaction(
            id=new_id(),
            user_id=user.id,
            budget_type=budget_type,
            title=title.strip(),
            amount=amount,
            tx_type=tx_type,
            category=category,
            icon=icon,
            occurred_at=occurred_at or datetime.now(UTC),
        )
        db.add(tx)
        db.commit()
        db.refresh(tx)
        return tx

    def _ensure_month_data(self, db: Session, user: User, month: str) -> None:
        has_any = (
            db.query(FinanceTransaction.id)
            .filter(FinanceTransaction.user_id == user.id)
            .limit(1)
            .one_or_none()
        )
        if has_any:
            for budget_type in (BudgetType.home.value, BudgetType.business.value):
                self._ensure_plan(db, user.id, budget_type, month)
            return

        now = datetime.now(UTC)
        day = now.day
        seed_rows = [
            (BudgetType.home.value, "סופרמרקט (מזון)", 450, TransactionType.expense.value, "food", "cart", day, 18, 0),
            (BudgetType.home.value, "מסעדה (בילויים)", 180, TransactionType.expense.value, "leisure", "restaurant", day, 20, 30),
            (BudgetType.home.value, "שכר דירה (קבוע)", 3200, TransactionType.expense.value, "housing", "home", 1, 9, 0),
            (BudgetType.home.value, "משכורת", 12000, TransactionType.income.value, "salary", "salary", 1, 9, 0),
            (BudgetType.business.value, "תשלום לקוח", 15000, TransactionType.income.value, "client", "salary", day, 11, 0),
            (BudgetType.business.value, "משרד (שכירות)", 1200, TransactionType.expense.value, "office", "home", 1, 10, 0),
            (BudgetType.business.value, "מנוי תוכנה", 350, TransactionType.expense.value, "software", "cart", day - 2 if day > 2 else day, 14, 0),
        ]

        for budget_type in (BudgetType.home.value, BudgetType.business.value):
            self._ensure_plan(db, user.id, budget_type, month)

        for row in seed_rows:
            btype, title, amount, tx_type, category, icon, tx_day, hour, minute = row
            tx_day = max(1, min(tx_day, 28))
            occurred = datetime.combine(
                date.fromisoformat(f"{month}-{tx_day:02d}"),
                time(hour, minute),
                tzinfo=UTC,
            )
            db.add(
                FinanceTransaction(
                    id=new_id(),
                    user_id=user.id,
                    budget_type=btype,
                    title=title,
                    amount=float(amount),
                    tx_type=tx_type,
                    category=category,
                    icon=icon,
                    occurred_at=occurred,
                )
            )
        db.commit()

    def _ensure_plan(self, db: Session, user_id: str, budget_type: str, month: str) -> BudgetPlan:
        plan = (
            db.query(BudgetPlan)
            .filter(
                BudgetPlan.user_id == user_id,
                BudgetPlan.budget_type == budget_type,
                BudgetPlan.month == month,
            )
            .one_or_none()
        )
        if plan:
            return plan

        defaults = DEFAULT_PLANS[budget_type]
        plan = BudgetPlan(
            id=new_id(),
            user_id=user_id,
            budget_type=budget_type,
            month=month,
            expense_budget=defaults["expense_budget"],
            savings_target=defaults["savings_target"],
        )
        db.add(plan)
        db.commit()
        db.refresh(plan)
        return plan

    def _summary(self, db: Session, user: User, budget_type: str, month: str) -> dict:
        plan = self._ensure_plan(db, user.id, budget_type, month)
        start, end = self._month_bounds(month)

        txs = (
            db.query(FinanceTransaction)
            .filter(
                FinanceTransaction.user_id == user.id,
                FinanceTransaction.budget_type == budget_type,
                FinanceTransaction.occurred_at >= start,
                FinanceTransaction.occurred_at < end,
            )
            .all()
        )

        income = sum(t.amount for t in txs if t.tx_type == TransactionType.income.value)
        expenses = sum(t.amount for t in txs if t.tx_type == TransactionType.expense.value)
        balance = income - expenses
        budget_remaining = max(0.0, plan.expense_budget - expenses)
        savings_saved = max(0.0, balance)
        savings_progress = (
            min(100.0, round((savings_saved / plan.savings_target) * 100, 1))
            if plan.savings_target > 0
            else 0.0
        )

        return {
            "budget_type": budget_type,
            "income": income,
            "expenses": expenses,
            "balance": balance,
            "expense_budget": plan.expense_budget,
            "budget_remaining": budget_remaining,
            "savings_target": plan.savings_target,
            "savings_saved": savings_saved,
            "savings_progress": savings_progress,
        }

    def _list_transactions(self, db: Session, user: User, budget_type: str, month: str) -> list[dict]:
        start, end = self._month_bounds(month)
        txs = (
            db.query(FinanceTransaction)
            .filter(
                FinanceTransaction.user_id == user.id,
                FinanceTransaction.budget_type == budget_type,
                FinanceTransaction.occurred_at >= start,
                FinanceTransaction.occurred_at < end,
            )
            .order_by(FinanceTransaction.occurred_at.desc())
            .limit(30)
            .all()
        )
        return [self._tx_to_dict(tx) for tx in txs]

    @staticmethod
    def _tx_to_dict(tx: FinanceTransaction) -> dict:
        signed = tx.amount if tx.tx_type == TransactionType.income.value else -tx.amount
        return {
            "id": tx.id,
            "title": tx.title,
            "time": tx.occurred_at.strftime("%d.%m %H:%M"),
            "amount": signed,
            "icon": tx.icon,
            "budget_type": tx.budget_type,
            "category": tx.category,
            "tx_type": tx.tx_type,
        }

    @staticmethod
    def _current_month() -> str:
        return date.today().strftime("%Y-%m")

    @staticmethod
    def _month_bounds(month: str) -> tuple[datetime, datetime]:
        year, mon = map(int, month.split("-"))
        start = datetime(year, mon, 1, tzinfo=UTC)
        if mon == 12:
            end = datetime(year + 1, 1, 1, tzinfo=UTC)
        else:
            end = datetime(year, mon + 1, 1, tzinfo=UTC)
        return start, end

    @staticmethod
    def _month_label(month: str) -> str:
        year, mon = map(int, month.split("-"))
        return f"{HEBREW_MONTHS[mon - 1]} {year}"
