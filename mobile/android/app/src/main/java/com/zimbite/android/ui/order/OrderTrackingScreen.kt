package com.zimbite.android.ui.order

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun OrderTrackingScreen(
    orderId: String,
    viewModel: OrderTrackingViewModel = hiltViewModel()
) {
    LaunchedEffect(orderId) { viewModel.startTracking(orderId) }

    val uiState by viewModel.uiState.collectAsState()

    Column(Modifier.fillMaxSize().padding(24.dp)) {
        Text("Order Tracking", style = MaterialTheme.typography.headlineSmall)
        Spacer(Modifier.height(16.dp))

        if (uiState.loading) {
            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
            return
        }

        if (uiState.error != null) {
            Text(uiState.error!!, color = MaterialTheme.colorScheme.error)
            return
        }

        uiState.tracking?.let { tracking ->
            Card(Modifier.fillMaxWidth()) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    StatusRow("Status", tracking.status)
                    StatusRow("Rider", tracking.riderId ?: "Assigning…")
                    StatusRow("ETA", tracking.estimatedArrivalAt ?: "Calculating…")
                    if (tracking.lastLatitude != null && tracking.lastLongitude != null) {
                        StatusRow("Last location", "${"%.4f".format(tracking.lastLatitude)}, ${"%.4f".format(tracking.lastLongitude)}")
                    }
                }
            }
        }
    }
}

@Composable
private fun StatusRow(label: String, value: String) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Text(value, style = MaterialTheme.typography.bodyMedium)
    }
}
