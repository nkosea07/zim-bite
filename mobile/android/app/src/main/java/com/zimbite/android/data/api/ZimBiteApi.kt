package com.zimbite.android.data.api

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass
import retrofit2.http.*

// ── Auth ──────────────────────────────────────────────────────────────────────

@JsonClass(generateAdapter = true)
data class LoginRequest(@Json(name = "phone") val phone: String, @Json(name = "password") val password: String)

@JsonClass(generateAdapter = true)
data class TokensResponse(
    @Json(name = "accessToken") val accessToken: String,
    @Json(name = "refreshToken") val refreshToken: String
)

// ── Vendors ───────────────────────────────────────────────────────────────────

@JsonClass(generateAdapter = true)
data class VendorDto(
    @Json(name = "id") val id: String,
    @Json(name = "name") val name: String,
    @Json(name = "description") val description: String?,
    @Json(name = "ratingAvg") val ratingAvg: Double,
    @Json(name = "deliveryRadiusKm") val deliveryRadiusKm: Double,
    @Json(name = "isActive") val isActive: Boolean
)

// ── Menu ──────────────────────────────────────────────────────────────────────

@JsonClass(generateAdapter = true)
data class MenuItemDto(
    @Json(name = "id") val id: String,
    @Json(name = "name") val name: String,
    @Json(name = "description") val description: String?,
    @Json(name = "basePrice") val basePrice: Double,
    @Json(name = "currency") val currency: String,
    @Json(name = "available") val available: Boolean,
    @Json(name = "calories") val calories: Int?
)

// ── Orders ────────────────────────────────────────────────────────────────────

@JsonClass(generateAdapter = true)
data class PlaceOrderRequest(
    @Json(name = "vendorId") val vendorId: String,
    @Json(name = "deliveryAddressId") val deliveryAddressId: String,
    @Json(name = "currency") val currency: String,
    @Json(name = "items") val items: List<OrderItemRequest>,
    @Json(name = "scheduledFor") val scheduledFor: String? = null
)

@JsonClass(generateAdapter = true)
data class OrderItemRequest(
    @Json(name = "menuItemId") val menuItemId: String,
    @Json(name = "quantity") val quantity: Int
)

@JsonClass(generateAdapter = true)
data class OrderResponse(
    @Json(name = "orderId") val orderId: String,
    @Json(name = "status") val status: String,
    @Json(name = "totalAmount") val totalAmount: Double,
    @Json(name = "currency") val currency: String,
    @Json(name = "scheduledFor") val scheduledFor: String?
)

// ── Delivery tracking ─────────────────────────────────────────────────────────

@JsonClass(generateAdapter = true)
data class TrackingResponse(
    @Json(name = "orderId") val orderId: String,
    @Json(name = "deliveryId") val deliveryId: String,
    @Json(name = "riderId") val riderId: String?,
    @Json(name = "status") val status: String,
    @Json(name = "lastLatitude") val lastLatitude: Double?,
    @Json(name = "lastLongitude") val lastLongitude: Double?,
    @Json(name = "estimatedArrivalAt") val estimatedArrivalAt: String?
)

// ── Retrofit interface ────────────────────────────────────────────────────────

interface ZimBiteApi {

    @POST("api/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): TokensResponse

    @GET("api/v1/vendors")
    suspend fun listVendors(): List<VendorDto>

    @GET("api/v1/menu/items")
    suspend fun listMenuItems(@Query("vendorId") vendorId: String): List<MenuItemDto>

    @POST("api/v1/orders")
    suspend fun placeOrder(@Body request: PlaceOrderRequest): OrderResponse

    @GET("api/v1/deliveries/orders/{orderId}/tracking")
    suspend fun getTracking(@Path("orderId") orderId: String): TrackingResponse
}
