package com.zimbite.android.ui

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.zimbite.android.ui.auth.LoginScreen
import com.zimbite.android.ui.home.HomeScreen
import com.zimbite.android.ui.mealbuilder.MealBuilderScreen
import com.zimbite.android.ui.order.OrderTrackingScreen
import com.zimbite.android.ui.vendor.VendorListScreen

object Routes {
    const val LOGIN = "login"
    const val HOME = "home"
    const val VENDORS = "vendors"
    const val MEAL_BUILDER = "meal-builder"
    const val ORDER_TRACKING = "order-tracking/{orderId}"
    fun orderTracking(orderId: String) = "order-tracking/$orderId"
}

@Composable
fun ZimBiteNavHost() {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = Routes.LOGIN) {
        composable(Routes.LOGIN) {
            LoginScreen(onLoginSuccess = { navController.navigate(Routes.HOME) { popUpTo(Routes.LOGIN) { inclusive = true } } })
        }
        composable(Routes.HOME) {
            HomeScreen(
                onBrowseVendors = { navController.navigate(Routes.VENDORS) },
                onBuildMeal = { navController.navigate(Routes.MEAL_BUILDER) }
            )
        }
        composable(Routes.VENDORS) {
            VendorListScreen(onVendorSelected = { navController.navigate(Routes.MEAL_BUILDER) })
        }
        composable(Routes.MEAL_BUILDER) {
            MealBuilderScreen(onOrderPlaced = { orderId -> navController.navigate(Routes.orderTracking(orderId)) })
        }
        composable(Routes.ORDER_TRACKING) { backStack ->
            val orderId = backStack.arguments?.getString("orderId") ?: return@composable
            OrderTrackingScreen(orderId = orderId)
        }
    }
}
