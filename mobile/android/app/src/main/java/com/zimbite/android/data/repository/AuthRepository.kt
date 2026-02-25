package com.zimbite.android.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.zimbite.android.data.api.LoginRequest
import com.zimbite.android.data.api.ZimBiteApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val api: ZimBiteApi,
    private val dataStore: DataStore<Preferences>
) {
    companion object {
        private val ACCESS_TOKEN_KEY = stringPreferencesKey("access_token")
        private val REFRESH_TOKEN_KEY = stringPreferencesKey("refresh_token")
    }

    val accessToken: Flow<String?> = dataStore.data.map { it[ACCESS_TOKEN_KEY] }

    suspend fun login(phone: String, password: String): Result<Unit> = runCatching {
        val tokens = api.login(LoginRequest(phone, password))
        dataStore.edit { prefs ->
            prefs[ACCESS_TOKEN_KEY] = tokens.accessToken
            prefs[REFRESH_TOKEN_KEY] = tokens.refreshToken
        }
    }

    suspend fun logout() {
        dataStore.edit { it.clear() }
    }
}
