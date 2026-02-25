package com.zimbite.android.ui.home

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun HomeScreen(
    onBrowseVendors: () -> Unit,
    onBuildMeal: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Good morning!", style = MaterialTheme.typography.headlineMedium)
        Text("Order before 10AM for fresh delivery", style = MaterialTheme.typography.bodyMedium)
        Spacer(Modifier.height(40.dp))
        Button(onClick = onBrowseVendors, modifier = Modifier.fillMaxWidth()) {
            Text("Browse Vendors")
        }
        Spacer(Modifier.height(16.dp))
        OutlinedButton(onClick = onBuildMeal, modifier = Modifier.fillMaxWidth()) {
            Text("Build My Breakfast")
        }
    }
}
