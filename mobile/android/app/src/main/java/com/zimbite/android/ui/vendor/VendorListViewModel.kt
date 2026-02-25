package com.zimbite.android.ui.vendor

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zimbite.android.data.api.VendorDto
import com.zimbite.android.data.api.ZimBiteApi
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class VendorListUiState(
    val vendors: List<VendorDto> = emptyList(),
    val loading: Boolean = true,
    val error: String? = null
)

@HiltViewModel
class VendorListViewModel @Inject constructor(private val api: ZimBiteApi) : ViewModel() {

    private val _uiState = MutableStateFlow(VendorListUiState())
    val uiState: StateFlow<VendorListUiState> = _uiState

    init {
        loadVendors()
    }

    private fun loadVendors() {
        viewModelScope.launch {
            _uiState.update { it.copy(loading = true, error = null) }
            runCatching { api.listVendors() }
                .onSuccess { vendors -> _uiState.update { it.copy(vendors = vendors, loading = false) } }
                .onFailure { e -> _uiState.update { it.copy(loading = false, error = e.message ?: "Failed to load vendors") } }
        }
    }
}
