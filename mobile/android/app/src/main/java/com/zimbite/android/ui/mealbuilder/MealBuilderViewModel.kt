package com.zimbite.android.ui.mealbuilder

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zimbite.android.data.api.MenuItemDto
import com.zimbite.android.data.api.OrderItemRequest
import com.zimbite.android.data.api.PlaceOrderRequest
import com.zimbite.android.data.api.ZimBiteApi
import com.zimbite.android.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class MealBuilderUiState(
    val menuItems: List<MenuItemDto> = emptyList(),
    val basket: Map<String, Int> = emptyMap(),
    val loading: Boolean = true,
    val placingOrder: Boolean = false,
    val error: String? = null,
    val placedOrderId: String? = null
) {
    val totalFormatted: String
        get() {
            val currency = menuItems.firstOrNull()?.currency ?: "USD"
            val total = menuItems.sumOf { item -> (basket[item.id] ?: 0) * item.basePrice }
            return "$currency ${"%.2f".format(total)}"
        }
}

@HiltViewModel
class MealBuilderViewModel @Inject constructor(
    private val api: ZimBiteApi,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(MealBuilderUiState())
    val uiState: StateFlow<MealBuilderUiState> = _uiState

    // Placeholder vendorId — in production this is passed via nav argument
    private var vendorId: String = ""
    private var deliveryAddressId: String = ""

    init {
        loadMenu()
    }

    private fun loadMenu() {
        viewModelScope.launch {
            runCatching { api.listVendors() }
                .onSuccess { vendors ->
                    val firstVendor = vendors.firstOrNull { it.isActive }
                    if (firstVendor == null) {
                        _uiState.update { it.copy(loading = false, error = "No active vendors found") }
                        return@launch
                    }
                    vendorId = firstVendor.id
                    runCatching { api.listMenuItems(vendorId) }
                        .onSuccess { items -> _uiState.update { it.copy(menuItems = items, loading = false) } }
                        .onFailure { e -> _uiState.update { it.copy(loading = false, error = e.message) } }
                }
                .onFailure { e -> _uiState.update { it.copy(loading = false, error = e.message) } }
        }
    }

    fun increment(itemId: String) {
        _uiState.update { state ->
            val current = state.basket[itemId] ?: 0
            state.copy(basket = state.basket + (itemId to current + 1))
        }
    }

    fun decrement(itemId: String) {
        _uiState.update { state ->
            val current = state.basket[itemId] ?: 0
            val updated = if (current <= 1) state.basket - itemId else state.basket + (itemId to current - 1)
            state.copy(basket = updated)
        }
    }

    fun placeOrder() {
        val state = _uiState.value
        if (state.basket.isEmpty()) return
        viewModelScope.launch {
            _uiState.update { it.copy(placingOrder = true, error = null) }
            val items = state.basket.map { (id, qty) -> OrderItemRequest(id, qty) }
            val request = PlaceOrderRequest(
                vendorId = vendorId,
                deliveryAddressId = deliveryAddressId.ifBlank { "00000000-0000-0000-0000-000000000001" },
                currency = "USD",
                items = items
            )
            runCatching { api.placeOrder(request) }
                .onSuccess { order -> _uiState.update { it.copy(placingOrder = false, placedOrderId = order.orderId) } }
                .onFailure { e -> _uiState.update { it.copy(placingOrder = false, error = e.message ?: "Order failed") } }
        }
    }
}
