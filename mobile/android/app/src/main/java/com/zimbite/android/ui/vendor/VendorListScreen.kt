package com.zimbite.android.ui.vendor

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.zimbite.android.data.api.VendorDto

@Composable
fun VendorListScreen(
    onVendorSelected: (vendorId: String) -> Unit,
    viewModel: VendorListViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    if (uiState.loading) {
        Box(Modifier.fillMaxSize(), contentAlignment = androidx.compose.ui.Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    if (uiState.error != null) {
        Box(Modifier.fillMaxSize().padding(24.dp), contentAlignment = androidx.compose.ui.Alignment.Center) {
            Text(uiState.error!!, color = MaterialTheme.colorScheme.error)
        }
        return
    }

    LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        item { Text("Nearby Vendors", style = MaterialTheme.typography.headlineSmall) }
        items(uiState.vendors) { vendor ->
            VendorCard(vendor = vendor, onClick = { onVendorSelected(vendor.id) })
        }
    }
}

@Composable
private fun VendorCard(vendor: VendorDto, onClick: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth().clickable(onClick = onClick)) {
        Column(Modifier.padding(16.dp)) {
            Text(vendor.name, style = MaterialTheme.typography.titleMedium)
            if (vendor.description != null) {
                Text(vendor.description, style = MaterialTheme.typography.bodySmall, maxLines = 2)
            }
            Spacer(Modifier.height(4.dp))
            Text("★ ${"%.1f".format(vendor.ratingAvg)}  •  ${vendor.deliveryRadiusKm} km radius",
                style = MaterialTheme.typography.labelSmall)
        }
    }
}
