package com.zimbite.android

import com.zimbite.android.data.api.MenuItemDto
import com.zimbite.android.data.api.OrderResponse
import com.zimbite.android.data.api.VendorDto
import com.zimbite.android.data.api.ZimBiteApi
import com.zimbite.android.data.repository.AuthRepository
import com.zimbite.android.ui.mealbuilder.MealBuilderViewModel
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
class MealBuilderViewModelTest {

    private val testDispatcher = UnconfinedTestDispatcher()
    private lateinit var api: ZimBiteApi
    private lateinit var authRepository: AuthRepository
    private lateinit var viewModel: MealBuilderViewModel

    private val testVendor = VendorDto("v1", "Test Vendor", null, 4.5, 5.0, true)
    private val testItem = MenuItemDto("item1", "Sadza & Eggs", null, 3.50, "USD", true, 420)

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        api = mockk()
        authRepository = mockk()
        coEvery { api.listVendors() } returns listOf(testVendor)
        coEvery { api.listMenuItems("v1") } returns listOf(testItem)
        viewModel = MealBuilderViewModel(api, authRepository)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `initial load populates menu items`() {
        val state = viewModel.uiState.value
        assertEquals(listOf(testItem), state.menuItems)
        assertEquals(false, state.loading)
        assertNull(state.error)
    }

    @Test
    fun `increment adds item to basket`() {
        viewModel.increment("item1")
        assertEquals(1, viewModel.uiState.value.basket["item1"])
    }

    @Test
    fun `decrement removes item when quantity reaches zero`() {
        viewModel.increment("item1")
        viewModel.decrement("item1")
        assertNull(viewModel.uiState.value.basket["item1"])
    }

    @Test
    fun `total is calculated correctly`() {
        viewModel.increment("item1")
        viewModel.increment("item1")
        assertEquals("USD 7.00", viewModel.uiState.value.totalFormatted)
    }

    @Test
    fun `placeOrder on success sets placedOrderId`() = runTest {
        val orderId = "order-abc"
        coEvery { api.placeOrder(any()) } returns OrderResponse(orderId, "PENDING_PAYMENT", 3.50, "USD", null)
        viewModel.increment("item1")
        viewModel.placeOrder()
        assertEquals(orderId, viewModel.uiState.value.placedOrderId)
    }

    @Test
    fun `placeOrder on failure sets error`() = runTest {
        coEvery { api.placeOrder(any()) } throws RuntimeException("Network error")
        viewModel.increment("item1")
        viewModel.placeOrder()
        assertNotNull(viewModel.uiState.value.error)
    }
}
