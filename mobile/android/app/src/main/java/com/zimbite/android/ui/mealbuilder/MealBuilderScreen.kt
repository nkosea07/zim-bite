package com.zimbite.android.ui.mealbuilder

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zimbite.android.data.api.MenuItemDto

@Composable
fun MealBuilderScreen(
    onOrderPlaced: (orderId: String) -> Unit,
    viewModel: MealBuilderViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.placedOrderId) {
        uiState.placedOrderId?.let { onOrderPlaced(it) }
    }

    if (uiState.loading) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
        return
    }

    Column(Modifier.fillMaxSize()) {
        LazyColumn(
            modifier = Modifier.weight(1f),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item { Text("Build Your Breakfast", style = MaterialTheme.typography.headlineSmall) }
            item { Text("Tap items to add them to your meal", style = MaterialTheme.typography.bodySmall) }
            items(uiState.menuItems) { item ->
                MealItemCard(
                    item = item,
                    quantity = uiState.basket[item.id] ?: 0,
                    onIncrement = { viewModel.increment(item.id) },
                    onDecrement = { viewModel.decrement(item.id) }
                )
            }
        }

        if (uiState.basket.isNotEmpty()) {
            Surface(shadowElevation = 8.dp) {
                Column(Modifier.padding(16.dp)) {
                    Text("Total: ${uiState.totalFormatted}", style = MaterialTheme.typography.titleMedium)
                    Spacer(Modifier.height(8.dp))
                    if (uiState.error != null) {
                        Text(uiState.error!!, color = MaterialTheme.colorScheme.error)
                        Spacer(Modifier.height(4.dp))
                    }
                    Button(
                        onClick = viewModel::placeOrder,
                        enabled = !uiState.placingOrder,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        if (uiState.placingOrder) CircularProgressIndicator(Modifier.size(20.dp))
                        else Text("Place Order")
                    }
                }
            }
        }
    }
}

@Composable
private fun MealItemCard(
    item: MenuItemDto,
    quantity: Int,
    onIncrement: () -> Unit,
    onDecrement: () -> Unit
) {
    Card(Modifier.fillMaxWidth()) {
        Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(item.name, style = MaterialTheme.typography.bodyLarge)
                Text("${item.currency} ${"%.2f".format(item.basePrice)}", style = MaterialTheme.typography.bodySmall)
                if (item.calories != null) Text("${item.calories} kcal", style = MaterialTheme.typography.labelSmall)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (quantity > 0) {
                    IconButton(onClick = onDecrement) { Text("−") }
                    Text("$quantity", Modifier.padding(horizontal = 4.dp))
                }
                IconButton(onClick = onIncrement, enabled = item.available) { Text("+") }
            }
        }
    }
}
