package com.zimbite.android.ui.order

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zimbite.android.data.api.TrackingResponse
import com.zimbite.android.data.api.ZimBiteApi
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import javax.inject.Inject

data class TrackingUiState(
    val tracking: TrackingResponse? = null,
    val loading: Boolean = true,
    val error: String? = null
)

@HiltViewModel
class OrderTrackingViewModel @Inject constructor(private val api: ZimBiteApi) : ViewModel() {

    private val _uiState = MutableStateFlow(TrackingUiState())
    val uiState: StateFlow<TrackingUiState> = _uiState

    fun startTracking(orderId: String) {
        viewModelScope.launch {
            while (isActive) {
                runCatching { api.getTracking(orderId) }
                    .onSuccess { tracking ->
                        _uiState.update { it.copy(tracking = tracking, loading = false, error = null) }
                        if (tracking.status == "DELIVERED") return@launch
                    }
                    .onFailure { e ->
                        _uiState.update { it.copy(loading = false, error = e.message ?: "Tracking unavailable") }
                    }
                delay(15_000L) // poll every 15 seconds — low-bandwidth friendly
            }
        }
    }
}
