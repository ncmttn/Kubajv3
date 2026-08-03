package com.kubaj.android.ui

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.isImeVisible
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.border
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.CreateNewFolder
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.DonutLarge
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.FolderOpen
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Inventory2
import androidx.compose.material.icons.filled.Park
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.TableView
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.Checkbox
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.kubaj.android.AppUiState
import com.kubaj.android.AppViewModel
import com.kubaj.android.R
import com.kubaj.android.data.AppTheme
import com.kubaj.android.data.FolderEntity
import com.kubaj.android.data.LANGUAGE_LOADING
import com.kubaj.android.domain.CalculationMethod
import com.kubaj.android.domain.DraftEntry
import com.kubaj.android.domain.LogEntryDisplay
import com.kubaj.android.domain.LogGrouping
import com.kubaj.android.export.ExportMetadata
import com.kubaj.android.export.Exporters
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private enum class MainTab(val label: Int, val icon: ImageVector) {
    HOME(R.string.tab_home, Icons.Default.Home),
    GROUPING(R.string.tab_grouping, Icons.Default.Inventory2),
    FOLDERS(R.string.tab_folders, Icons.Default.Folder),
    SETTINGS(R.string.tab_settings, Icons.Default.Settings)
}

@Composable
fun KubajRoot(viewModel: AppViewModel) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    var splash by rememberSaveable { mutableStateOf(true) }

    LaunchedEffect(state.preferences.language) {
        if (state.preferences.language != LANGUAGE_LOADING) {
            val locales = LocaleListCompat.forLanguageTags(state.preferences.language)
            if (AppCompatDelegate.getApplicationLocales() != locales) {
                AppCompatDelegate.setApplicationLocales(locales)
            }
        }
    }
    LaunchedEffect(Unit) {
        delay(1_600)
        splash = false
    }

    KubajTheme(state.preferences.theme) {
        when {
            splash -> SplashScreen()
            !state.preferences.onboardingCompleted -> OnboardingScreen(
                state.preferences.hapticsEnabled,
                viewModel::completeOnboarding
            )
            else -> MainScreen(state, viewModel)
        }
    }
}

@Composable
private fun SplashScreen() {
    Box(
        Modifier
            .fillMaxSize()
            .background(Brush.linearGradient(listOf(KubajPrimary, KubajPrimaryEnd))),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                Modifier
                    .size(110.dp)
                    .background(Color.White, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.Park, null, tint = KubajPrimary, modifier = Modifier.size(56.dp))
            }
            Spacer(Modifier.height(24.dp))
            Text(stringResource(R.string.app_name), color = Color.White, fontSize = 40.sp, fontWeight = FontWeight.Black)
            Text(stringResource(R.string.splash_tagline), color = Color.White.copy(alpha = 0.85f))
        }
    }
}

@Composable
private fun OnboardingScreen(hapticsEnabled: Boolean, onComplete: () -> Unit) {
    var page by rememberSaveable { mutableIntStateOf(0) }
    val haptic = hapticAction(hapticsEnabled)
    val titles = listOf(
        R.string.onboarding_title_1,
        R.string.onboarding_title_2,
        R.string.onboarding_title_3
    )
    val bodies = listOf(
        R.string.onboarding_body_1,
        R.string.onboarding_body_2,
        R.string.onboarding_body_3
    )
    Column(
        Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(horizontal = 32.dp, vertical = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .aspectRatio(4f / 5f)
                    .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(40.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    when (page) {
                        0 -> Icons.Default.Calculate
                        1 -> Icons.Default.Inventory2
                        else -> Icons.Default.Description
                    },
                    null,
                    tint = MaterialTheme.colorScheme.primary.copy(alpha = 0.35f),
                    modifier = Modifier.size(80.dp)
                )
                Row(
                    Modifier
                        .align(Alignment.TopStart)
                        .padding(24.dp)
                        .background(KubajPrimary.copy(alpha = 0.82f), RoundedCornerShape(20.dp))
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Park, null, tint = Color.White, modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(8.dp))
                    Text(
                        stringResource(R.string.app_name).uppercase(),
                        color = Color.White,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                }
            }
            Spacer(Modifier.height(32.dp))
            Text(
                stringResource(titles[page]),
                fontSize = 34.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center
            )
            Spacer(Modifier.height(14.dp))
            Text(
                stringResource(bodies[page]),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 16.sp
            )
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                repeat(3) { index ->
                    Box(
                        Modifier
                            .width(if (index == page) 32.dp else 6.dp)
                            .height(6.dp)
                            .background(
                                if (index == page) MaterialTheme.colorScheme.primary
                                else MaterialTheme.colorScheme.surfaceVariant,
                                CircleShape
                            )
                    )
                }
            }
            Spacer(Modifier.height(28.dp))
            Button(
                onClick = {
                    haptic()
                    if (page == 2) onComplete() else page++
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp),
                shape = RoundedCornerShape(24.dp)
            ) {
                Text(
                    stringResource(if (page == 2) R.string.get_started else R.string.next),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            if (page < 2) {
                Spacer(Modifier.height(8.dp))
                TextButton(onClick = { haptic(); onComplete() }, modifier = Modifier.fillMaxWidth()) {
                    Text(stringResource(R.string.skip_intro))
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun MainScreen(state: AppUiState, viewModel: AppViewModel) {
    var selected by rememberSaveable { mutableStateOf(MainTab.HOME) }
    val haptic = hapticAction(state.preferences.hapticsEnabled)
    val imeVisible = WindowInsets.isImeVisible
    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = {
            if (!imeVisible) {
                Row(
                    Modifier
                        .navigationBarsPadding()
                        .padding(horizontal = 8.dp)
                        .height(62.dp)
                        .background(
                            MaterialTheme.colorScheme.surfaceContainerLowest.copy(alpha = 0.96f),
                            RoundedCornerShape(32.dp)
                        )
                        .padding(horizontal = 20.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    MainTab.entries.forEach { tab ->
                        val active = selected == tab
                        Column(
                            Modifier
                                .weight(1f)
                                .clickable {
                                    haptic()
                                    selected = tab
                                }
                                .padding(vertical = 7.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Icon(
                                tab.icon,
                                null,
                                tint = if (active) MaterialTheme.colorScheme.primary else KubajTabInactive,
                                modifier = Modifier.size(18.dp)
                            )
                            Text(
                                stringResource(tab.label).uppercase(),
                                maxLines = 1,
                                fontSize = 10.sp,
                                color = if (active) MaterialTheme.colorScheme.primary else KubajTabInactive
                            )
                        }
                    }
                }
            }
        }
    ) { padding ->
        when (selected) {
            MainTab.HOME -> HomeScreen(
                state,
                viewModel,
                Modifier.padding(padding)
            ) { selected = MainTab.GROUPING }
            MainTab.GROUPING -> GroupingScreen(state, viewModel, Modifier.padding(padding))
            MainTab.FOLDERS -> FoldersScreen(state, Modifier.padding(padding)) { folderId ->
                viewModel.selectFolder(folderId)
                selected = MainTab.GROUPING
            }
            MainTab.SETTINGS -> SettingsScreen(state, viewModel, Modifier.padding(padding))
        }
    }
}

@Composable
private fun ScreenHeader(title: String, actions: @Composable () -> Unit = {}) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceContainerLowest)
            .padding(horizontal = 24.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(Icons.Default.Park, null, tint = MaterialTheme.colorScheme.primary)
        Spacer(Modifier.width(10.dp))
        Text(title, fontSize = 20.sp, fontWeight = FontWeight.Bold, letterSpacing = (-1).sp)
        Spacer(Modifier.weight(1f))
        actions()
    }
}

@Composable
private fun HomeScreen(
    state: AppUiState,
    viewModel: AppViewModel,
    modifier: Modifier,
    onViewFullHistory: () -> Unit
) {
    var diameter by rememberSaveable { mutableStateOf("21") }
    var top by rememberSaveable { mutableStateOf("21") }
    var mid by rememberSaveable { mutableStateOf("21") }
    var butt by rememberSaveable { mutableStateOf("21") }
    var width by rememberSaveable { mutableStateOf("21") }
    var thickness by rememberSaveable { mutableStateOf("") }
    var length by rememberSaveable { mutableStateOf("") }
    var quantity by rememberSaveable { mutableStateOf("1") }
    var showHollow by rememberSaveable { mutableStateOf(false) }
    var showSave by rememberSaveable { mutableStateOf(false) }
    var clearConfirm by rememberSaveable { mutableStateOf(false) }
    var deleteEntryId by rememberSaveable { mutableStateOf<String?>(null) }
    val primaryFocusRequester = remember { FocusRequester() }
    var primarySelectAllTrigger by rememberSaveable { mutableIntStateOf(0) }
    val haptic = hapticAction(state.preferences.hapticsEnabled)
    val listState = rememberLazyListState()
    val previousTopDraftId = remember { mutableStateOf<String?>(null) }

    LaunchedEffect(state.drafts.firstOrNull()?.id) {
        val topId = state.drafts.firstOrNull()?.id
        if (previousTopDraftId.value != null && topId != null && topId != previousTopDraftId.value) {
            delay(80)
            listState.animateScrollToItem(4)
        }
        previousTopDraftId.value = topId
    }

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name)) {
            IconButton(
                enabled = state.drafts.isNotEmpty(),
                onClick = { haptic(); showSave = true },
                modifier = Modifier
                    .size(32.dp)
                    .background(MaterialTheme.colorScheme.surfaceVariant, CircleShape)
            ) {
                Icon(Icons.Default.Save, null, modifier = Modifier.size(17.dp))
            }
        }
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp)
        ) {
            item {
                val method = state.preferences.calculationMethod
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    when (method) {
                        CalculationMethod.HUBER -> InputPair {
                            NumberField(
                                stringResource(R.string.diameter_cm),
                                diameter,
                                { diameter = it },
                                Modifier.weight(1f),
                                focusRequester = primaryFocusRequester,
                                selectAllTrigger = primarySelectAllTrigger
                            ) {
                                TextButton(onClick = {
                                    haptic()
                                    diameter = ((diameter.toLocalizedDoubleOrNull() ?: 21.0) + 1).toInt().toString()
                                }) { Text("+1", fontSize = 21.sp, fontWeight = FontWeight.Black) }
                            }
                            NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                        }
                        CalculationMethod.SMALIAN -> {
                            InputPair {
                                NumberField(
                                    stringResource(R.string.top_diameter_cm),
                                    top,
                                    { top = it },
                                    Modifier.weight(1f),
                                    focusRequester = primaryFocusRequester,
                                    selectAllTrigger = primarySelectAllTrigger
                                )
                                NumberField(stringResource(R.string.butt_diameter_cm), butt, { butt = it }, Modifier.weight(1f))
                            }
                            InputPair {
                                NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, Modifier.weight(1f), true)
                            }
                        }
                        CalculationMethod.NEWTON -> {
                            InputPair {
                                NumberField(
                                    stringResource(R.string.top_diameter_cm),
                                    top,
                                    { top = it },
                                    Modifier.weight(1f),
                                    focusRequester = primaryFocusRequester,
                                    selectAllTrigger = primarySelectAllTrigger
                                )
                                NumberField(stringResource(R.string.butt_diameter_cm), butt, { butt = it }, Modifier.weight(1f))
                            }
                            InputPair {
                                NumberField(stringResource(R.string.mid_diameter_cm), mid, { mid = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                            }
                        }
                        CalculationMethod.LUMBER -> {
                            InputPair {
                                NumberField(
                                    stringResource(R.string.width_cm),
                                    width,
                                    { width = it },
                                    Modifier.weight(1f),
                                    focusRequester = primaryFocusRequester,
                                    selectAllTrigger = primarySelectAllTrigger
                                )
                                NumberField(
                                    stringResource(R.string.thickness_cm),
                                    thickness,
                                    { thickness = it },
                                    Modifier.weight(1f)
                                )
                            }
                            InputPair {
                                NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, Modifier.weight(1f), true)
                            }
                        }
                    }
                    if (method == CalculationMethod.HUBER) {
                        NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, Modifier.fillMaxWidth(0.5f), true)
                    } else if (method == CalculationMethod.NEWTON) {
                        NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, Modifier.fillMaxWidth(0.5f), true)
                    }
                }
            }
            item {
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    FilledTonalButton(
                        onClick = { haptic(); showHollow = true },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(24.dp)
                    ) {
                        Icon(Icons.Default.DonutLarge, null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(6.dp))
                        Text(stringResource(R.string.calculate_hollow), maxLines = 1)
                    }
                    Button(
                        onClick = {
                            haptic()
                            val added = viewModel.addStandard(
                                diameter.toLocalizedDoubleOrNull(),
                                top.toLocalizedDoubleOrNull(),
                                mid.toLocalizedDoubleOrNull(),
                                butt.toLocalizedDoubleOrNull(),
                                width.toLocalizedDoubleOrNull(),
                                thickness.toLocalizedDoubleOrNull(),
                                length.toLocalizedDoubleOrNull(),
                                quantity.toIntOrNull()
                            )
                            if (added) {
                                quantity = "1"
                                primarySelectAllTrigger++
                                primaryFocusRequester.requestFocus()
                            }
                        },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(24.dp)
                    ) {
                        Text(stringResource(R.string.calculate))
                    }
                }
            }
            item {
                val count = state.drafts.sumOf { it.quantity }
                val total = state.drafts.sumOf { it.totalVolumeM3 }
                HomeStatsCard(total, count) { haptic(); clearConfirm = true }
            }
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(stringResource(R.string.calculations), fontSize = 25.sp, fontWeight = FontWeight.Black)
                    Spacer(Modifier.weight(1f))
                    if (state.drafts.isNotEmpty()) {
                        IconButton(onClick = { haptic(); clearConfirm = true }) { Icon(Icons.Default.Delete, null) }
                    }
                }
            }
            if (state.drafts.isEmpty()) {
                item { EmptyState(stringResource(R.string.empty_calculations)) }
            } else {
                item {
                    DraftTable(
                        entries = state.drafts,
                        onIncrease = { haptic(); viewModel.increaseDraft(it) },
                        onDecrease = { haptic(); viewModel.decreaseDraft(it) },
                        onDelete = { haptic(); deleteEntryId = it }
                    )
                }
            }
            item {
                TextButton(onClick = { haptic(); onViewFullHistory() }, modifier = Modifier.fillMaxWidth()) {
                    Text(
                        stringResource(R.string.tab_grouping),
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }

    if (showHollow) HollowSheet(
        viewModel,
        state.preferences.hapticsEnabled
    ) { showHollow = false }
    if (showSave) SaveDialog(
        state.folders,
        viewModel,
        state.preferences.hapticsEnabled,
        onDismiss = { showSave = false }
    )
    if (clearConfirm) ConfirmDialog(
        onDismiss = { clearConfirm = false },
        onConfirm = { haptic(); viewModel.clearDrafts(); clearConfirm = false }
    )
    if (deleteEntryId != null) ConfirmDialog(
        onDismiss = { deleteEntryId = null },
        onConfirm = {
            haptic()
            deleteEntryId?.let(viewModel::deleteDraft)
            deleteEntryId = null
        }
    )
}

@Composable
private fun InputPair(content: @Composable RowScope.() -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(10.dp), content = content)
}

@Composable
private fun DraftTable(
    entries: List<DraftEntry>,
    onIncrease: (String) -> Unit,
    onDecrease: (String) -> Unit,
    onDelete: (String) -> Unit
) {
    val bands = LogGrouping.lengthBands(entries.map { it.lengthM })
    Column(Modifier.background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))) {
        Row(
            Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f))
                .padding(horizontal = 10.dp, vertical = 12.dp)
        ) {
            TableTitle(stringResource(R.string.table_no), Modifier.weight(0.45f))
            TableTitle(stringResource(R.string.table_length), Modifier.weight(0.7f))
            TableTitle(stringResource(R.string.table_quantity), Modifier.weight(0.6f))
            TableTitle(stringResource(R.string.table_diameter), Modifier.weight(0.85f))
            TableTitle(stringResource(R.string.table_volume), Modifier.weight(0.9f))
            Spacer(Modifier.width(84.dp))
        }
        entries.forEachIndexed { index, entry ->
            Row(
                Modifier
                    .fillMaxWidth()
                    .background(
                        if (bands[index] == 1) MaterialTheme.colorScheme.primary.copy(alpha = 0.055f)
                        else Color.Transparent
                    )
                    .padding(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                TableValue((index + 1).toString(), Modifier.weight(0.45f))
                TableValue(lengthFormat.format(entry.lengthM), Modifier.weight(0.7f))
                TableValue(entry.quantity.toString(), Modifier.weight(0.6f))
                TableValue(LogEntryDisplay.diameterLabel(entry), Modifier.weight(0.85f))
                Text(
                    volumeFormat.format(entry.totalVolumeM3),
                    Modifier.weight(0.9f),
                    color = MaterialTheme.colorScheme.primary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    maxLines = 1
                )
                Row(Modifier.width(84.dp)) {
                    IconButton(
                        onClick = { onIncrease(entry.id) },
                        modifier = Modifier.size(28.dp)
                    ) { Icon(Icons.Default.Add, null, modifier = Modifier.size(17.dp)) }
                    IconButton(
                        onClick = { onDecrease(entry.id) },
                        modifier = Modifier.size(28.dp)
                    ) { Icon(Icons.Default.Remove, null, modifier = Modifier.size(17.dp)) }
                    IconButton(
                        onClick = { onDelete(entry.id) },
                        modifier = Modifier.size(28.dp)
                    ) { Icon(Icons.Default.Delete, null, tint = KubajDanger, modifier = Modifier.size(17.dp)) }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun HollowSheet(
    viewModel: AppViewModel,
    hapticsEnabled: Boolean,
    onDismiss: () -> Unit
) {
    var outer by rememberSaveable { mutableStateOf("") }
    var inner by rememberSaveable { mutableStateOf("") }
    var length by rememberSaveable { mutableStateOf("") }
    val values = listOf(
        outer.toLocalizedDoubleOrNull(),
        inner.toLocalizedDoubleOrNull(),
        length.toLocalizedDoubleOrNull()
    )
    val valid = values.all { it != null && it > 0 } &&
        (values[0] ?: 0.0) > (values[1] ?: 0.0)
    val result = if (valid) viewModel.calculateHollow(values[0]!!, values[1]!!, values[2]!!) else null
    val haptic = hapticAction(hapticsEnabled)

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(Modifier.fillMaxWidth()) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(stringResource(R.string.calculate_hollow), fontSize = 22.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.weight(1f))
                TextButton(onClick = { haptic(); onDismiss() }) { Text(stringResource(R.string.cancel)) }
            }
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 24.dp, vertical = 20.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                item {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        InputPair {
                            NumberField(stringResource(R.string.outer_diameter), outer, { outer = it }, Modifier.weight(1f))
                            NumberField(stringResource(R.string.inner_diameter), inner, { inner = it }, Modifier.weight(1f))
                        }
                        NumberField(stringResource(R.string.length_m), length, { length = it })
                    }
                }
                result?.let { preview ->
                    item {
                        Column(
                            Modifier
                                .fillMaxWidth()
                                .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(24.dp))
                                .padding(24.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                stringResource(R.string.equivalent_diameter, preview.equivalentDiameterCm),
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                stringResource(R.string.net_volume, preview.netVolumeM3),
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
                item {
                    Button(
                        enabled = valid,
                        onClick = {
                            haptic()
                            viewModel.addHollow(
                                values[0]!!,
                                values[1]!!,
                                values[2]!!,
                                1
                            )
                            onDismiss()
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(52.dp),
                        shape = RoundedCornerShape(24.dp)
                    ) { Text(stringResource(R.string.add_to_list), fontWeight = FontWeight.Bold) }
                }
                result?.let { preview ->
                    item {
                        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                            Text(
                                stringResource(R.string.equivalent_diameter, preview.equivalentDiameterCm).uppercase(),
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 1.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                FilledTonalButton(
                                    enabled = preview.equivalentDiameterCm > 1,
                                    onClick = {
                                        haptic()
                                        viewModel.addEquivalentDiameter(
                                            preview.equivalentDiameterCm - 1,
                                            values[2]!!,
                                            1
                                        )
                                        onDismiss()
                                    },
                                    modifier = Modifier.weight(1f),
                                    shape = RoundedCornerShape(24.dp)
                                ) { Text(stringResource(R.string.add_diameter, preview.equivalentDiameterCm - 1)) }
                                FilledTonalButton(
                                    onClick = {
                                        haptic()
                                        viewModel.addEquivalentDiameter(
                                            preview.equivalentDiameterCm + 1,
                                            values[2]!!,
                                            1
                                        )
                                        onDismiss()
                                    },
                                    modifier = Modifier.weight(1f),
                                    shape = RoundedCornerShape(24.dp)
                                ) { Text(stringResource(R.string.add_diameter, preview.equivalentDiameterCm + 1)) }
                            }
                        }
                    }
                }
            }
    }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SaveDialog(
    folders: List<FolderEntity>,
    viewModel: AppViewModel,
    hapticsEnabled: Boolean,
    onDismiss: () -> Unit
) {
    var selectedFolderId by rememberSaveable { mutableStateOf<Long?>(null) }
    var expandedIds by remember { mutableStateOf(setOf<Long>()) }
    var createParentId by rememberSaveable { mutableStateOf<Long?>(null) }
    var showCreateDialog by rememberSaveable { mutableStateOf(false) }
    var newFolderName by rememberSaveable { mutableStateOf("") }
    val haptic = hapticAction(hapticsEnabled)
    val roots = remember(folders) {
        folders.filter { it.parentId == null }.sortedBy { it.name.lowercase() }
    }

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(stringResource(R.string.select_file), fontSize = 22.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.weight(1f))
                TextButton(onClick = { haptic(); onDismiss() }) { Text(stringResource(R.string.cancel)) }
            }

            if (roots.isEmpty()) {
                EmptyState(stringResource(R.string.no_folders))
            } else {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(max = 360.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    items(roots, key = { it.id }) { folder ->
                        FolderTreeNode(
                            folder = folder,
                            folders = folders,
                            depth = 0,
                            selectedFolderId = selectedFolderId,
                            expandedIds = expandedIds,
                            onToggleExpand = { id ->
                                haptic()
                                expandedIds = if (id in expandedIds) expandedIds - id else expandedIds + id
                            },
                            onSelect = { id ->
                                haptic()
                                selectedFolderId = id
                            },
                            onCreateSubfolder = { parentId ->
                                haptic()
                                createParentId = parentId
                                newFolderName = ""
                                showCreateDialog = true
                            }
                        )
                    }
                }
            }

            FilledTonalButton(
                onClick = {
                    haptic()
                    createParentId = null
                    newFolderName = ""
                    showCreateDialog = true
                },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp)
            ) {
                Icon(Icons.Default.CreateNewFolder, null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text(stringResource(R.string.create_file), fontWeight = FontWeight.SemiBold)
            }

            Button(
                enabled = selectedFolderId != null,
                onClick = {
                    haptic()
                    selectedFolderId?.let(viewModel::saveDrafts)
                    onDismiss()
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(16.dp)
            ) { Text(stringResource(R.string.save_here), fontWeight = FontWeight.Bold) }
        }
    }

    if (showCreateDialog) {
        AlertDialog(
            onDismissRequest = { showCreateDialog = false },
            title = {
                Text(
                    stringResource(
                        if (createParentId == null) R.string.create_file else R.string.create_subfolder
                    )
                )
            },
            text = {
                OutlinedTextField(
                    value = newFolderName,
                    onValueChange = { newFolderName = it },
                    label = { Text(stringResource(R.string.file_name)) },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
            },
            confirmButton = {
                TextButton(
                    enabled = newFolderName.isNotBlank(),
                    onClick = {
                        haptic()
                        val parentId = createParentId
                        viewModel.createFolder(newFolderName, parentId) { createdId ->
                            selectedFolderId = createdId
                            if (parentId != null) {
                                expandedIds = expandedIds + parentId
                            }
                        }
                        newFolderName = ""
                        createParentId = null
                        showCreateDialog = false
                    }
                ) { Text(stringResource(R.string.create)) }
            },
            dismissButton = {
                TextButton(onClick = {
                    showCreateDialog = false
                    createParentId = null
                    newFolderName = ""
                }) { Text(stringResource(R.string.cancel)) }
            }
        )
    }
}

@Composable
private fun FolderTreeNode(
    folder: FolderEntity,
    folders: List<FolderEntity>,
    depth: Int,
    selectedFolderId: Long?,
    expandedIds: Set<Long>,
    onToggleExpand: (Long) -> Unit,
    onSelect: (Long) -> Unit,
    onCreateSubfolder: (Long) -> Unit
) {
    val children = remember(folders, folder.id) {
        folders.filter { it.parentId == folder.id }.sortedBy { it.name.lowercase() }
    }
    val expanded = folder.id in expandedIds
    val selected = selectedFolderId == folder.id

    Column {
        Row(
            Modifier
                .fillMaxWidth()
                .background(
                    if (selected) KubajPrimary.copy(alpha = 0.10f)
                    else MaterialTheme.colorScheme.surfaceContainerLowest,
                    RoundedCornerShape(12.dp)
                )
                .clickable { onSelect(folder.id) }
                .padding(start = (14 + depth * 16).dp, end = 8.dp, top = 10.dp, bottom = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = { onToggleExpand(folder.id) },
                modifier = Modifier.size(32.dp)
            ) {
                Icon(
                    if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Icon(
                if (selected) Icons.Default.Folder else Icons.Default.FolderOpen,
                null,
                tint = if (selected) KubajPrimary else MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(20.dp)
            )
            Spacer(Modifier.width(10.dp))
            Text(
                folder.name,
                Modifier.weight(1f),
                fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Normal
            )
            if (selected) {
                Icon(Icons.Default.CheckCircle, null, tint = KubajGreen, modifier = Modifier.size(20.dp))
            }
        }

        if (expanded) {
            if (children.isEmpty()) {
                Text(
                    stringResource(R.string.no_subfolders),
                    modifier = Modifier.padding(start = (46 + depth * 16).dp, top = 4.dp, bottom = 4.dp),
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                children.forEach { child ->
                    FolderTreeNode(
                        folder = child,
                        folders = folders,
                        depth = depth + 1,
                        selectedFolderId = selectedFolderId,
                        expandedIds = expandedIds,
                        onToggleExpand = onToggleExpand,
                        onSelect = onSelect,
                        onCreateSubfolder = onCreateSubfolder
                    )
                }
            }
            TextButton(
                onClick = { onCreateSubfolder(folder.id) },
                modifier = Modifier.padding(start = (30 + depth * 16).dp)
            ) {
                Icon(Icons.Default.CreateNewFolder, null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text(stringResource(R.string.create_subfolder), fontSize = 13.sp)
            }
        }
    }
}

@Composable
private fun GroupingScreen(state: AppUiState, viewModel: AppViewModel, modifier: Modifier) {
    val context = LocalContext.current
    var folderMenu by remember { mutableStateOf(false) }
    var exportType by remember { mutableStateOf<String?>(null) }
    var deleteConfirm by remember { mutableStateOf(false) }
    var groupToDelete by remember { mutableStateOf<com.kubaj.android.domain.LogGroup?>(null) }
    var pendingExportFile by remember { mutableStateOf<java.io.File?>(null) }
    var pendingSaveLaunch by remember { mutableStateOf<Pair<String, String>?>(null) }
    val haptic = hapticAction(state.preferences.hapticsEnabled)
    val exportSavedMessage = stringResource(R.string.export_saved)
    val exportFailedMessage = stringResource(R.string.export_failed)
    val groups = if (state.selectedFolderId == null) {
        LogGrouping.sort(LogGrouping.groupDrafts(state.drafts), state.sortAscending)
    } else state.groups

    val savePdfLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument("application/pdf")
    ) { uri ->
        val file = pendingExportFile
        pendingExportFile = null
        if (uri != null && file != null) {
            runCatching {
                Exporters.copyToUri(context, file, uri)
                Toast.makeText(context, exportSavedMessage, Toast.LENGTH_SHORT).show()
            }.onFailure {
                Toast.makeText(context, exportFailedMessage, Toast.LENGTH_SHORT).show()
            }
        }
    }
    val saveXlsxLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        )
    ) { uri ->
        val file = pendingExportFile
        pendingExportFile = null
        if (uri != null && file != null) {
            runCatching {
                Exporters.copyToUri(context, file, uri)
                Toast.makeText(context, exportSavedMessage, Toast.LENGTH_SHORT).show()
            }.onFailure {
                Toast.makeText(context, exportFailedMessage, Toast.LENGTH_SHORT).show()
            }
        }
    }

    LaunchedEffect(pendingSaveLaunch) {
        val launch = pendingSaveLaunch ?: return@LaunchedEffect
        delay(350)
        if (launch.first == "pdf") {
            savePdfLauncher.launch(launch.second)
        } else {
            saveXlsxLauncher.launch(launch.second)
        }
        pendingSaveLaunch = null
    }

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name)) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(start = 12.dp)
            ) {
                IconButton(
                    enabled = groups.isNotEmpty(),
                    onClick = { haptic(); exportType = "pdf" },
                    modifier = Modifier
                        .size(32.dp)
                        .background(MaterialTheme.colorScheme.surfaceVariant, CircleShape)
                ) {
                    Icon(Icons.Default.Description, null, modifier = Modifier.size(17.dp), tint = KubajDanger)
                }
                IconButton(
                    enabled = groups.isNotEmpty(),
                    onClick = { haptic(); exportType = "xlsx" },
                    modifier = Modifier
                        .size(32.dp)
                        .background(MaterialTheme.colorScheme.surfaceVariant, CircleShape)
                ) {
                    Icon(Icons.Default.TableView, null, modifier = Modifier.size(17.dp), tint = KubajGreen)
                }
                IconButton(
                    enabled = state.selectedFolder != null,
                    onClick = { haptic(); deleteConfirm = true },
                    modifier = Modifier
                        .size(32.dp)
                        .background(MaterialTheme.colorScheme.surfaceVariant, CircleShape)
                ) {
                    Icon(Icons.Default.Delete, null, tint = KubajDanger, modifier = Modifier.size(17.dp))
                }
            }
        }
        LazyColumn(
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            item {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        stringResource(R.string.select_file).uppercase(),
                        modifier = Modifier.padding(start = 8.dp),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Box {
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .background(MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(12.dp))
                                .clickable { haptic(); folderMenu = true }
                                .padding(horizontal = 16.dp, vertical = 14.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                state.selectedFolder?.let { folderPath(it, state.folders) }
                                    ?: stringResource(R.string.active_session),
                                Modifier.weight(1f),
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Text("⌄", color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                        DropdownMenu(folderMenu, { folderMenu = false }) {
                            DropdownMenuItem(
                                text = { Text(stringResource(R.string.active_session)) },
                                onClick = { haptic(); viewModel.selectFolder(null); folderMenu = false }
                            )
                            state.folders.forEach {
                                DropdownMenuItem(
                                    text = { Text(folderPath(it, state.folders)) },
                                    onClick = { haptic(); viewModel.selectFolder(it.id); folderMenu = false }
                                )
                            }
                        }
                    }
                }
            }
            item {
                val count = groups.sumOf { it.totalQuantity }
                GroupOverview(
                    totalVolume = groups.sumOf { it.totalVolumeM3 },
                    productCount = count
                )
            }
            if (groups.isEmpty()) item { EmptyState(stringResource(R.string.grouping_empty)) }
            else item {
                GroupTable(
                    groups,
                    sortAscending = state.sortAscending,
                    onToggleSort = { haptic(); viewModel.toggleSort() },
                    hapticsEnabled = state.preferences.hapticsEnabled,
                    onIncrease = {
                        if (state.selectedFolderId == null) viewModel.increaseDraftGroup(it)
                        else viewModel.increaseGroup(it)
                    },
                    onDecrease = {
                        if (state.selectedFolderId == null) viewModel.decreaseDraftGroup(it)
                        else viewModel.decreaseGroup(it)
                    },
                    onDelete = {
                        haptic()
                        groupToDelete = it
                    }
                )
            }
        }
    }

    exportType?.let { type ->
        ExportDialog(
            type,
            groups,
            state.preferences.hapticsEnabled,
            onDismiss = { exportType = null }
        ) { fileName, metadata ->
            runCatching {
                val safeName = fileName.trim().ifBlank { "kubaj-export" }
                    .replace(Regex("""[\\/:*?"<>|\s]+"""), "_")
                val file = if (type == "pdf") {
                    Exporters.createPdf(context, safeName, groups, metadata)
                } else {
                    Exporters.createXlsx(context, safeName, groups)
                }
                pendingExportFile = file
                exportType = null
                pendingSaveLaunch = type to if (type == "pdf") "$safeName.pdf" else "$safeName.xlsx"
            }.onFailure {
                exportType = null
                Toast.makeText(context, exportFailedMessage, Toast.LENGTH_SHORT).show()
            }
        }
    }
    if (deleteConfirm) ConfirmDialog(
        onDismiss = { deleteConfirm = false },
        onConfirm = {
            haptic()
            state.selectedFolder?.let(viewModel::deleteFolder)
            deleteConfirm = false
        }
    )
    groupToDelete?.let { group ->
        ConfirmDialog(
            onDismiss = { groupToDelete = null },
            onConfirm = {
                haptic()
                if (state.selectedFolderId == null) viewModel.deleteDraftGroup(group)
                else viewModel.deleteGroup(group)
                groupToDelete = null
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ExportDialog(
    type: String,
    groups: List<com.kubaj.android.domain.LogGroup>,
    hapticsEnabled: Boolean,
    onDismiss: () -> Unit,
    onExport: (String, ExportMetadata) -> Unit
) {
    var fileName by rememberSaveable { mutableStateOf("kubaj") }
    var company by rememberSaveable { mutableStateOf("") }
    var date by rememberSaveable { mutableStateOf("") }
    var location by rememberSaveable { mutableStateOf("") }
    var reporter by rememberSaveable { mutableStateOf("") }
    var code by rememberSaveable { mutableStateOf("") }
    val haptic = hapticAction(hapticsEnabled)
    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(Modifier.fillMaxWidth()) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(stringResource(R.string.export_settings), fontSize = 22.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.weight(1f))
                TextButton(onClick = { haptic(); onDismiss() }) { Text(stringResource(R.string.cancel)) }
            }
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 24.dp, vertical = 16.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                item {
                    Column(
                        Modifier
                            .fillMaxWidth()
                            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(32.dp))
                            .padding(24.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        OutlinedTextField(fileName, { fileName = it }, label = { Text(stringResource(R.string.export_file_name)) })
                        OutlinedTextField(company, { company = it }, label = { Text(stringResource(R.string.company_name)) })
                        OutlinedTextField(date, { date = it }, label = { Text(stringResource(R.string.report_date)) })
                        OutlinedTextField(location, { location = it }, label = { Text(stringResource(R.string.location)) })
                        OutlinedTextField(reporter, { reporter = it }, label = { Text(stringResource(R.string.reporter)) })
                        OutlinedTextField(code, { code = it }, label = { Text(stringResource(R.string.project_code)) })
                    }
                }
                item {
                    Button(
                        enabled = groups.isNotEmpty(),
                        onClick = {
                            haptic()
                            onExport(
                                fileName,
                                ExportMetadata(listOf(company, date, location, reporter, code))
                            )
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp),
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Icon(
                            if (type == "pdf") Icons.Default.Description else Icons.Default.TableView,
                            null
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            if (type == "pdf") stringResource(R.string.export_pdf)
                            else stringResource(R.string.export_excel)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun FoldersScreen(
    state: AppUiState,
    modifier: Modifier,
    onFolderSelected: (Long) -> Unit
) {
    val haptic = hapticAction(state.preferences.hapticsEnabled)
    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name))
        LazyColumn(
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 32.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            item {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        stringResource(R.string.tab_folders),
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        stringResource(R.string.select_file),
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            val usedFolderIds = state.records.map { it.folderId }.toSet()
            val visible = state.folders
                .filter { it.id in usedFolderIds }
                .sortedBy { folderPath(it, state.folders).lowercase() }
            if (visible.isEmpty()) item { EmptyState(stringResource(R.string.folders_empty)) }
            items(visible, key = { it.id }) { folder ->
                Row(
                    Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surfaceContainerLowest, RoundedCornerShape(12.dp))
                        .clickable { haptic(); onFolderSelected(folder.id) }
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Folder, null, tint = MaterialTheme.colorScheme.primary)
                    Spacer(Modifier.width(12.dp))
                    Column(Modifier.weight(1f)) {
                        Text(folderPath(folder, state.folders), fontWeight = FontWeight.SemiBold)
                        Text(
                            "${state.records.count { it.folderId == folder.id }} ${stringResource(R.string.product_count)}",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Text("›", fontSize = 22.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}

@Composable
private fun SettingsScreen(state: AppUiState, viewModel: AppViewModel, modifier: Modifier) {
    var languageMenu by remember { mutableStateOf(false) }
    val languages = listOf("", "tr", "en", "de", "es", "pt", "fr", "sv", "fi", "ru")
    val haptic = hapticAction(state.preferences.hapticsEnabled)

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name))
        LazyColumn(
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 28.dp),
            verticalArrangement = Arrangement.spacedBy(28.dp)
        ) {
            item {
                SettingsSection(stringResource(R.string.tab_settings)) {
                    Column {
                        Row(
                            Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                Modifier
                                    .size(40.dp)
                                    .background(KubajPrimary.copy(alpha = 0.12f), RoundedCornerShape(10.dp)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Default.Settings, null, tint = MaterialTheme.colorScheme.primary)
                            }
                            Spacer(Modifier.width(12.dp))
                            Text(stringResource(R.string.settings_haptics), Modifier.weight(1f))
                            Switch(
                                state.preferences.hapticsEnabled,
                                onCheckedChange = {
                                    haptic()
                                    viewModel.setHaptics(it)
                                }
                            )
                        }
                        HorizontalDivider(Modifier.padding(horizontal = 16.dp))
                        Column(Modifier.padding(12.dp)) {
                            AppTheme.entries.forEach { theme ->
                                SettingChoice(
                                    text = stringResource(
                                        when (theme) {
                                            AppTheme.SYSTEM -> R.string.theme_system
                                            AppTheme.LIGHT -> R.string.theme_light
                                            AppTheme.DARK -> R.string.theme_dark
                                        }
                                    ),
                                    selected = state.preferences.theme == theme,
                                    onClick = { haptic(); viewModel.setTheme(theme) }
                                )
                            }
                        }
                    }
                }
            }
            item {
                SettingsSection(stringResource(R.string.settings_calculation_methods)) {
                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                Modifier
                                    .size(40.dp)
                                    .background(KubajPrimary.copy(alpha = 0.12f), RoundedCornerShape(10.dp)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Default.Calculate, null, tint = KubajPrimary)
                            }
                            Spacer(Modifier.width(12.dp))
                            Text(stringResource(R.string.settings_calculation_methods), fontWeight = FontWeight.SemiBold)
                        }
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            FormulaOption(
                                stringResource(R.string.formula_smalian),
                                state.preferences.calculationMethod == CalculationMethod.SMALIAN,
                                Modifier.weight(1f)
                            ) { haptic(); viewModel.setMethod(CalculationMethod.SMALIAN) }
                            FormulaOption(
                                stringResource(R.string.formula_huber),
                                state.preferences.calculationMethod == CalculationMethod.HUBER,
                                Modifier.weight(1f)
                            ) { haptic(); viewModel.setMethod(CalculationMethod.HUBER) }
                        }
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            FormulaOption(
                                stringResource(R.string.formula_newton),
                                state.preferences.calculationMethod == CalculationMethod.NEWTON,
                                Modifier.weight(1f)
                            ) { haptic(); viewModel.setMethod(CalculationMethod.NEWTON) }
                            FormulaOption(
                                stringResource(R.string.formula_ulker),
                                state.preferences.calculationMethod == CalculationMethod.LUMBER,
                                Modifier.weight(1f)
                            ) { haptic(); viewModel.setMethod(CalculationMethod.LUMBER) }
                        }
                    }
                }
            }
            item {
                SettingsSection(stringResource(R.string.settings_language)) {
                    Box {
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .background(MaterialTheme.colorScheme.surfaceContainerLowest, RoundedCornerShape(20.dp))
                                .clickable { haptic(); languageMenu = true }
                                .padding(horizontal = 16.dp, vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                Modifier
                                    .size(40.dp)
                                    .background(KubajPrimary.copy(alpha = 0.12f), RoundedCornerShape(10.dp)),
                                contentAlignment = Alignment.Center
                            ) {
                                Text("◎", color = KubajPrimary, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                            }
                            Spacer(Modifier.width(12.dp))
                            Column(Modifier.weight(1f)) {
                                Text(stringResource(R.string.settings_language), fontWeight = FontWeight.Medium)
                                Text(
                                    if (state.preferences.language.isBlank()) stringResource(R.string.theme_system)
                                    else state.preferences.language.uppercase(),
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    fontSize = 13.sp
                                )
                            }
                            Text("⌄", color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                        DropdownMenu(languageMenu, { languageMenu = false }) {
                            languages.forEach { language ->
                                DropdownMenuItem(
                                    text = {
                                        Text(
                                            if (language.isEmpty()) stringResource(R.string.theme_system)
                                            else language.uppercase()
                                        )
                                    },
                                    onClick = {
                                        haptic()
                                        viewModel.setLanguage(language)
                                        languageMenu = false
                                    }
                                )
                            }
                        }
                    }
                }
            }
            item {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        "WOODLOG V${com.kubaj.android.BuildConfig.VERSION_NAME}",
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.65f),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        textAlign = TextAlign.Center
                    )
                    Text(
                        "Necmettin Özarslan",
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                        fontSize = 10.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

@Composable
private fun FormulaOption(
    title: String,
    selected: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Column(
        modifier
            .background(
                if (selected) Brush.linearGradient(listOf(KubajPrimary, KubajPrimaryEnd))
                else Brush.linearGradient(
                    listOf(
                        MaterialTheme.colorScheme.surfaceContainerLowest,
                        MaterialTheme.colorScheme.surfaceContainerLowest
                    )
                ),
                RoundedCornerShape(12.dp)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 14.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            title,
            color = if (selected) Color.White else MaterialTheme.colorScheme.onSurface,
            fontWeight = FontWeight.SemiBold,
            maxLines = 1
        )
    }
}

@Composable
private fun SettingsSection(title: String, content: @Composable () -> Unit) {
    Column {
        Text(
            title.uppercase(),
            modifier = Modifier.padding(start = 16.dp),
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.5.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(12.dp))
        Column(
            Modifier
                .fillMaxWidth()
                .background(
                    MaterialTheme.colorScheme.surfaceContainerLowest,
                    RoundedCornerShape(20.dp)
                )
                .padding(4.dp)
        ) {
            content()
        }
    }
}

@Composable
private fun SettingChoice(text: String, selected: Boolean, onClick: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .background(
                if (selected) MaterialTheme.colorScheme.primary.copy(alpha = 0.10f)
                else MaterialTheme.colorScheme.surfaceContainerLowest,
                RoundedCornerShape(18.dp)
            )
            .padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        RadioButton(selected, onClick)
        Text(text, fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal)
    }
}

@Composable
private fun ConfirmDialog(onDismiss: () -> Unit, onConfirm: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        text = { Text(stringResource(R.string.delete_confirmation)) },
        confirmButton = { TextButton(onClick = onConfirm) { Text(stringResource(R.string.confirm)) } },
        dismissButton = { TextButton(onClick = onDismiss) { Text(stringResource(R.string.cancel)) } }
    )
}

private fun folderPath(folder: FolderEntity, folders: List<FolderEntity>): String {
    val names = mutableListOf(folder.name)
    var parent = folders.firstOrNull { it.id == folder.parentId }
    while (parent != null) {
        names.add(0, parent.name)
        parent = folders.firstOrNull { it.id == parent?.parentId }
    }
    return names.joinToString(" / ")
}

private fun String.toLocalizedDoubleOrNull(): Double? =
    trim().replace(',', '.').toDoubleOrNull()

@Composable
private fun hapticAction(enabled: Boolean): () -> Unit {
    val context = LocalContext.current
    return {
        if (enabled) {
            performAppHaptic(context)
        }
    }
}

fun performAppHaptic(context: Context) {
    val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        context.getSystemService(VibratorManager::class.java)?.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    } ?: return
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        vibrator.vibrate(VibrationEffect.createOneShot(45, VibrationEffect.DEFAULT_AMPLITUDE))
    } else {
        @Suppress("DEPRECATION")
        vibrator.vibrate(45)
    }
}
