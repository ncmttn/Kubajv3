package com.kubaj.android.data

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.kubaj.android.domain.CalculationMethod
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore("kubaj_preferences")

enum class AppTheme {
    SYSTEM,
    LIGHT,
    DARK
}

const val LANGUAGE_LOADING = "__loading__"

data class PreferenceState(
    val calculationMethod: CalculationMethod = CalculationMethod.HUBER,
    val theme: AppTheme = AppTheme.SYSTEM,
    val language: String = LANGUAGE_LOADING,
    val hapticsEnabled: Boolean = true,
    val onboardingCompleted: Boolean = false
)

class AppPreferences(private val context: Context) {
    private object Keys {
        val method = stringPreferencesKey("method")
        val theme = stringPreferencesKey("theme")
        val language = stringPreferencesKey("language")
        val haptics = booleanPreferencesKey("haptics")
        val onboarding = booleanPreferencesKey("onboarding")
    }

    val state: Flow<PreferenceState> = context.dataStore.data.map { values ->
        PreferenceState(
            calculationMethod = values[Keys.method]
                ?.let { runCatching { CalculationMethod.valueOf(it) }.getOrNull() }
                ?: CalculationMethod.HUBER,
            theme = values[Keys.theme]
                ?.let { runCatching { AppTheme.valueOf(it) }.getOrNull() }
                ?: AppTheme.SYSTEM,
            language = values[Keys.language].orEmpty(),
            hapticsEnabled = values[Keys.haptics] ?: true,
            onboardingCompleted = values[Keys.onboarding] ?: false
        )
    }

    suspend fun setMethod(value: CalculationMethod) =
        context.dataStore.edit { it[Keys.method] = value.name }

    suspend fun setTheme(value: AppTheme) =
        context.dataStore.edit { it[Keys.theme] = value.name }

    suspend fun setLanguage(value: String) =
        context.dataStore.edit { it[Keys.language] = value }

    suspend fun setHaptics(value: Boolean) =
        context.dataStore.edit { it[Keys.haptics] = value }

    suspend fun completeOnboarding() =
        context.dataStore.edit { it[Keys.onboarding] = true }
}
