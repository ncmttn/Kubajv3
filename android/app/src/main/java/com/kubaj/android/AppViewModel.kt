package com.kubaj.android

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.kubaj.android.data.AppTheme
import com.kubaj.android.data.FolderEntity
import com.kubaj.android.data.LogRecordEntity
import com.kubaj.android.data.PreferenceState
import com.kubaj.android.domain.CalculationMethod
import com.kubaj.android.domain.DraftEntry
import com.kubaj.android.domain.ForestryCalculator
import com.kubaj.android.domain.HollowResult
import com.kubaj.android.domain.LogGroup
import com.kubaj.android.domain.LogGrouping
import java.util.UUID
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class AppUiState(
    val preferences: PreferenceState = PreferenceState(),
    val folders: List<FolderEntity> = emptyList(),
    val records: List<LogRecordEntity> = emptyList(),
    val drafts: List<DraftEntry> = emptyList(),
    val selectedFolderId: Long? = null,
    val sortAscending: Boolean = false
) {
    val selectedFolder: FolderEntity? get() = folders.firstOrNull { it.id == selectedFolderId }
    val selectedRecords: List<LogRecordEntity>
        get() = selectedFolderId?.let { id -> records.filter { it.folderId == id } }.orEmpty()
    val groups: List<LogGroup>
        get() = LogGrouping.sort(LogGrouping.group(selectedRecords), sortAscending)
}

private data class BaseState(
    val preferences: PreferenceState,
    val folders: List<FolderEntity>,
    val records: List<LogRecordEntity>,
    val drafts: List<DraftEntry>,
    val selectedFolderId: Long?
)

class AppViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as KubajApplication
    private val dao = app.database.dao()
    private val drafts = MutableStateFlow<List<DraftEntry>>(emptyList())
    private val selectedFolderId = MutableStateFlow<Long?>(null)
    private val sortAscending = MutableStateFlow(false)

    private val baseState = combine(
        app.preferences.state,
        dao.observeFolders(),
        dao.observeRecords(),
        drafts,
        selectedFolderId
    ) { preferences, folders, records, draftEntries, folderId ->
        BaseState(preferences, folders, records, draftEntries, folderId)
    }

    val uiState: StateFlow<AppUiState> = combine(baseState, sortAscending) { base, ascending ->
        AppUiState(
            base.preferences,
            base.folders,
            base.records,
            base.drafts,
            base.selectedFolderId,
            ascending
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), AppUiState())

    fun addStandard(
        diameter: Double?,
        top: Double?,
        mid: Double?,
        butt: Double?,
        length: Double?,
        quantity: Int?
    ): Boolean {
        val state = uiState.value
        val safeLength = length?.takeIf { it > 0 } ?: return false
        val safeQuantity = quantity?.takeIf { it > 0 } ?: return false
        val method = state.preferences.calculationMethod
        val entry = when (method) {
            CalculationMethod.HUBER -> {
                val value = diameter?.takeIf { it > 0 } ?: return false
                DraftEntry(
                    UUID.randomUUID().toString(),
                    value,
                    safeLength,
                    safeQuantity,
                    ForestryCalculator.huber(value, safeLength),
                    method
                )
            }
            CalculationMethod.SMALIAN -> {
                val first = top?.takeIf { it > 0 } ?: return false
                val second = butt?.takeIf { it > 0 } ?: return false
                DraftEntry(
                    UUID.randomUUID().toString(),
                    first,
                    safeLength,
                    safeQuantity,
                    ForestryCalculator.smalian(first, second, safeLength),
                    method,
                    topDiameterCm = first,
                    buttDiameterCm = second
                )
            }
            CalculationMethod.NEWTON -> {
                val first = top?.takeIf { it > 0 } ?: return false
                val middle = mid?.takeIf { it > 0 } ?: return false
                val second = butt?.takeIf { it > 0 } ?: return false
                DraftEntry(
                    UUID.randomUUID().toString(),
                    middle,
                    safeLength,
                    safeQuantity,
                    ForestryCalculator.newton(first, middle, second, safeLength),
                    method,
                    topDiameterCm = first,
                    midDiameterCm = middle,
                    buttDiameterCm = second
                )
            }
        }
        drafts.update { listOf(entry) + it }
        return true
    }

    fun calculateHollow(outer: Double, inner: Double, length: Double): HollowResult =
        ForestryCalculator.hollow(outer, inner, length)

    fun addHollow(outer: Double, inner: Double, length: Double, quantity: Int) {
        val result = ForestryCalculator.hollow(outer, inner, length)
        drafts.update {
            listOf(
                DraftEntry(
                    UUID.randomUUID().toString(),
                    result.equivalentDiameterCm.toDouble(),
                    length,
                    quantity,
                    result.netVolumeM3,
                    CalculationMethod.HUBER,
                    isHollow = true
                )
            ) + it
        }
    }

    fun addEquivalentDiameter(diameter: Int, length: Double, quantity: Int) {
        drafts.update {
            listOf(
                DraftEntry(
                    UUID.randomUUID().toString(),
                    diameter.toDouble(),
                    length,
                    quantity,
                    ForestryCalculator.huber(diameter.toDouble(), length),
                    CalculationMethod.HUBER,
                    isHollow = true
                )
            ) + it
        }
    }

    fun increaseDraft(id: String) =
        drafts.update { values -> values.map { if (it.id == id) it.copy(quantity = it.quantity + 1) else it } }

    fun decreaseDraft(id: String) =
        drafts.update { values ->
            values.mapNotNull {
                when {
                    it.id != id -> it
                    it.quantity > 1 -> it.copy(quantity = it.quantity - 1)
                    else -> null
                }
            }
        }

    fun deleteDraft(id: String) = drafts.update { values -> values.filterNot { it.id == id } }
    fun increaseDraftGroup(group: LogGroup) {
        val target = matchingDraft(group) ?: return
        increaseDraft(target.id)
    }

    fun decreaseDraftGroup(group: LogGroup) {
        val target = matchingDraft(group) ?: return
        decreaseDraft(target.id)
    }

    fun deleteDraftGroup(group: LogGroup) {
        drafts.update { values ->
            values.filterNot { it.diameterCm == group.diameterCm && it.lengthM == group.lengthM }
        }
    }

    private fun matchingDraft(group: LogGroup): DraftEntry? =
        drafts.value
            .filter { it.diameterCm == group.diameterCm && it.lengthM == group.lengthM }
            .maxByOrNull { it.createdAt }

    fun clearDrafts() = drafts.update { emptyList() }
    fun selectFolder(id: Long?) = selectedFolderId.update { id }
    fun toggleSort() = sortAscending.update { !it }

    fun createFolder(name: String, parentId: Long? = null, onCreated: (Long) -> Unit = {}) {
        if (name.isBlank()) return
        viewModelScope.launch {
            onCreated(dao.insertFolder(FolderEntity(name = name.trim(), parentId = parentId)))
        }
    }

    fun saveDrafts(folderId: Long) {
        val values = drafts.value
        if (values.isEmpty()) return
        viewModelScope.launch {
            dao.insertRecords(values.map { draft ->
                LogRecordEntity(
                    folderId = folderId,
                    diameterCm = draft.diameterCm,
                    lengthM = draft.lengthM,
                    quantity = draft.quantity,
                    volumeM3 = draft.volumeM3,
                    calculationMethod = draft.method.name,
                    isHollow = draft.isHollow,
                    isLumber = draft.isLumber,
                    topDiameterCm = draft.topDiameterCm,
                    midDiameterCm = draft.midDiameterCm,
                    buttDiameterCm = draft.buttDiameterCm,
                    lumberThicknessCm = draft.lumberThicknessCm,
                    createdAt = draft.createdAt
                )
            })
            drafts.update { emptyList() }
        }
    }

    fun increaseGroup(group: LogGroup) {
        val record = group.records.maxByOrNull { it.createdAt } ?: return
        viewModelScope.launch { dao.updateRecord(record.copy(quantity = record.quantity + 1)) }
    }

    fun decreaseGroup(group: LogGroup) {
        val record = group.records.maxByOrNull { it.createdAt } ?: return
        viewModelScope.launch {
            if (record.quantity > 1) dao.updateRecord(record.copy(quantity = record.quantity - 1))
            else dao.deleteRecord(record)
        }
    }

    fun deleteGroup(group: LogGroup) {
        viewModelScope.launch { dao.deleteRecords(group.records.map { it.id }) }
    }

    fun deleteFolder(folder: FolderEntity) {
        viewModelScope.launch {
            dao.deleteFolder(folder)
            if (selectedFolderId.value == folder.id) selectedFolderId.update { null }
        }
    }

    fun setMethod(value: CalculationMethod) = viewModelScope.launch { app.preferences.setMethod(value) }
    fun setTheme(value: AppTheme) = viewModelScope.launch { app.preferences.setTheme(value) }
    fun setLanguage(value: String) = viewModelScope.launch { app.preferences.setLanguage(value) }
    fun setHaptics(value: Boolean) = viewModelScope.launch { app.preferences.setHaptics(value) }
    fun completeOnboarding() = viewModelScope.launch { app.preferences.completeOnboarding() }
}
