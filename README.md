# Order Pad

Order Pad is a Flutter application for managing restaurant orders, menu items, and customer feedback.

## Architecture

The application follows a **Service-Repository Pattern** combined with **MVC (Model-View-Controller)**, utilizing **GetX** for state management and dependency injection.

- **Models** (`lib/models`): Define the data structures and methods for serialization (e.g., `fromMap`, `toMap`).
- **Views** (`lib/screens`, `lib/widgets`): The UI layer built with Flutter widgets. Views observe Controllers to reactively update the UI.
- **Controllers** (`lib/screens/.../*_controller.dart`): Handle business logic, manage state using GetX observables (`Rx`), and act as a bridge between the UI and Services.
- **Services** (`lib/services`): The data access layer responsible for communicating with the backend (Supabase). They handle API calls and data fetching.

This separation of concerns ensures code maintainability, testability, and scalability.

## Controllers Documentation

### DashboardController
- **Purpose**: Manages the state of the Dashboard screen.
- **Key Functions**:
    - `fetchTopSellingMeals()`: Fetches top-selling meals from Supabase.
    - `fetchDashboardStats()`: Aggregates total sales and revenue data.
    - `selectCategory(id)`: Filters meals by category.

### MenuManagementController
- **Location**: `lib/screens/05_menu_management/menu_controller.dart`
- **Purpose**: Manages the state for the Menu Management screen (Categories, Meals, Ingredients).
- **Key Functions**:
    - `addCategory`, `updateCategory`, `deleteCategory`: CRUD operations for categories.
    - `addMeal`, `updateMeal`, `deleteMeal`: CRUD operations for meals.
    - `addIngredient`, `updateIngredient`, `deleteIngredient`: CRUD operations for ingredients.
    - `fetchMealIngredients(mealId)`: Fetches ingredients associated with a specific meal.

### MenuManagementService
- **Location**: `lib/screens/05_menu_management/menu_management_service.dart`
- **Purpose**: Handles database interactions for menu management.
- **Key Functions**:
    - `getCategories`, `addCategory`, `updateCategory`, `deleteCategory`.
    - `getMeals`, `addMeal`, `updateMeal`, `deleteMeal`.
    - `getIngredients`, `addIngredient`, `updateIngredient`, `deleteIngredient`.

### OrderHistoryController
- **Purpose**: Manages the Order History screen.
- **Key Functions**:
    - `fetchOrders()`: Fetches completed orders.
    - `toggleFilter()`: Toggles between showing all orders or only today's orders.
    - `rateOrder(orderId)`: Navigates to the Feedback screen for a specific order.

### OrderSelectionController
- **Purpose**: Manages the Order Selection screen for viewing reviews.
- **Key Functions**:
    - `fetchCompletedOrders()`: Fetches a list of completed orders to allow the user to select one for viewing reviews.

### OrderReviewsController
- **Purpose**: Manages the Order Reviews screen.
- **Key Functions**:
    - `fetchReviews()`: Fetches all reviews associated with a specific `orderId`, including meal details.

### Feedback Logic (in FeedbackScreen)
- **Purpose**: Handles the submission of new reviews.
- **Key Functions**:
    - `_submitReviews()`: Collects ratings and comments for each meal in an order and submits them to the `reviews` table via `ReviewService`.

## Business Logic Documentation

### Total Selling & Revenue Calculation
- **Location**: `lib/screens/01_dashboard/dashboard_service.dart` inside `getDashboardStats()`
- **Method**:
    - Fetches all records from the `view_meal_sales` view in Supabase.
    - Iterates through the result set locally.
    - **Total Sales**: Sums the `total_sold` column (count of items sold).
    - **Total Revenue**: Sums the product of `total_sold` * `meal_price` for each record.
    - **Note**: This aggregation is currently performed client-side. For larger datasets, it is recommended to move this logic to a server-side RPC or database view.
