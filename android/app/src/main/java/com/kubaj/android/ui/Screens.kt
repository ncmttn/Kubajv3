package com.kubaj.android.ui

import android.os.Build
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
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.border
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.DonutLarge
import androidx.compose.material.icons.filled.Folder
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
import com.kubaj.android.domain.LogGrouping
import com.kubaj.android.export.ExportMetadata
import com.kubaj.android.export.Exporters
import kotlinx.coroutines.delay

private enum class MainTab(val label: Int, val icon: ImageVector) {
    HOME(R.string.tab_home, Icons.Default.Home),
    GROUPING(R.string.tab_grouping, Icons.Default.Inventory2),
    HOLLOW(R.string.calculate_hollow, Icons.Default.DonutLarge),
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
            !state.preferences.onboardingCompleted -> OnboardingScreen(viewModel::completeOnboarding)
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
private fun OnboardingScreen(onComplete: () -> Unit) {
    var page by rememberSaveable { mutableIntStateOf(0) }
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
                    .height(330.dp)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                KubajPrimary.copy(alpha = 0.16f),
                                KubajPrimaryEnd.copy(alpha = 0.04f)
                            )
                        ),
                        RoundedCornerShape(32.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    Modifier
                        .size(150.dp)
                        .background(Color.White.copy(alpha = 0.9f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        when (page) {
                            0 -> Icons.Default.Calculate
                            1 -> Icons.Default.Inventory2
                            else -> Icons.Default.Description
                        },
                        null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(76.dp)
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
                onClick = { if (page == 2) onComplete() else page++ },
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
        }
    }
}

@Composable
private fun MainScreen(state: AppUiState, viewModel: AppViewModel) {
    var selected by rememberSaveable { mutableStateOf(MainTab.HOME) }
    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = {
            Row(
                Modifier
                    .navigationBarsPadding()
                    .height(64.dp)
                    .background(MaterialTheme.colorScheme.surface.copy(alpha = 0.96f), RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                    .padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                MainTab.entries.forEach { tab ->
                    val active = selected == tab
                    Column(
                        Modifier
                            .weight(1f)
                            .clickable { selected = tab }
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
                            stringResource(tab.label),
                            maxLines = 1,
                            fontSize = 9.sp,
                            color = if (active) MaterialTheme.colorScheme.primary else KubajTabInactive
                        )
                    }
                }
            }
        }
    ) { padding ->
        when (selected) {
            MainTab.HOME -> HomeScreen(state, viewModel, Modifier.padding(padding))
            MainTab.GROUPING -> GroupingScreen(state, viewModel, Modifier.padding(padding))
            MainTab.HOLLOW -> HollowScreen(viewModel, Modifier.padding(padding))
            MainTab.SETTINGS -> SettingsScreen(state, viewModel, Modifier.padding(padding))
        }
    }
}

@Composable
private fun ScreenHeader(title: String, actions: @Composable () -> Unit = {}) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface)
            .padding(horizontal = 20.dp, vertical = 18.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(Icons.Default.Park, null, tint = MaterialTheme.colorScheme.primary)
        Spacer(Modifier.width(10.dp))
        Text(title, fontSize = 21.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.weight(1f))
        actions()
    }
}

@Composable
private fun HomeScreen(state: AppUiState, viewModel: AppViewModel, modifier: Modifier) {
    var diameter by rememberSaveable { mutableStateOf("21") }
    var top by rememberSaveable { mutableStateOf("21") }
    var mid by rememberSaveable { mutableStateOf("21") }
    var butt by rememberSaveable { mutableStateOf("21") }
    var length by rememberSaveable { mutableStateOf("") }
    var quantity by rememberSaveable { mutableStateOf("1") }
    var showSave by rememberSaveable { mutableStateOf(false) }
    var clearConfirm by rememberSaveable { mutableStateOf(false) }
    val primaryFocusRequester = remember { FocusRequester() }
    var primarySelectAllTrigger by rememberSaveable { mutableIntStateOf(0) }

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name)) {
            IconButton(enabled = state.drafts.isNotEmpty(), onClick = { showSave = true }) {
                Icon(Icons.Default.Save, null)
            }
        }
        LazyColumn(
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
                                    diameter = ((diameter.toDoubleOrNull() ?: 21.0) + 1).toInt().toString()
                                }) { Text("+1") }
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
                    Spacer(Modifier.weight(1f))
                    Button(
                        onClick = {
                            val added = viewModel.addStandard(
                                diameter.toDoubleOrNull(),
                                top.toDoubleOrNull(),
                                mid.toDoubleOrNull(),
                                butt.toDoubleOrNull(),
                                length.toDoubleOrNull(),
                                quantity.toIntOrNull()
                            )
                            if (added) {
                                quantity = "1"
                                primarySelectAllTrigger++
                                primaryFocusRequester.requestFocus()
                            }
                        },
                        modifier = Modifier.weight(2f)
                    ) {
                        Text(stringResource(R.string.calculate))
                    }
                }
            }
            item {
                val count = state.drafts.sumOf { it.quantity }
                val total = state.drafts.sumOf { it.totalVolumeM3 }
                val average = if (count == 0) 0.0 else state.drafts.sumOf { it.diameterCm * it.quantity } / count
                SummaryCards(total, count, average)
            }
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(stringResource(R.string.calculations), fontSize = 21.sp, fontWeight = FontWeight.Bold)
                    Spacer(Modifier.weight(1f))
                    if (state.drafts.isNotEmpty()) {
                        IconButton(onClick = { clearConfirm = true }) { Icon(Icons.Default.Delete, null) }
                    }
                }
            }
            if (state.drafts.isEmpty()) {
                item { EmptyState(stringResource(R.string.empty_calculations)) }
            } else {
                item { DraftTable(state.drafts, viewModel) }
            }
        }
    }

    if (showSave) SaveDialog(state.folders, viewModel, onDismiss = { showSave = false })
    if (clearConfirm) ConfirmDialog(
        onDismiss = { clearConfirm = false },
        onConfirm = { viewModel.clearDrafts(); clearConfirm = false }
    )
}

@Composable
private fun InputPair(content: @Composable RowScope.() -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(10.dp), content = content)
}

@Composable
private fun DraftTable(entries: List<DraftEntry>, viewModel: AppViewModel) {
    val bands = LogGrouping.lengthBands(entries.map { it.lengthM })
    Column(Modifier.background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))) {
        Row(
            Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f))
                .padding(horizontal = 10.dp, vertical = 12.dp)
        ) {
            Text(stringResource(R.string.table_no), Modifier.width(28.dp), fontSize = 9.sp)
            Text(stringResource(R.string.table_quantity), Modifier.width(38.dp), fontSize = 9.sp)
            Text(stringResource(R.string.table_length), Modifier.width(48.dp), fontSize = 9.sp)
            Text(stringResource(R.string.table_diameter), Modifier.weight(1f), fontSize = 9.sp)
            Text(stringResource(R.string.table_volume), Modifier.width(58.dp), fontSize = 9.sp)
            Spacer(Modifier.width(70.dp))
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
                Text((index + 1).toString(), Modifier.width(28.dp))
                Text(entry.quantity.toString(), Modifier.width(38.dp))
                Text(lengthFormat.format(entry.lengthM), Modifier.width(48.dp))
                Text("Ø ${diameterFormat.format(entry.diameterCm)}", Modifier.weight(1f))
                Text(
                    volumeFormat.format(entry.totalVolumeM3),
                    Modifier.width(58.dp),
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
                Row(Modifier.width(70.dp)) {
                    IconButton(
                        onClick = { viewModel.increaseDraft(entry.id) },
                        modifier = Modifier.size(34.dp)
                    ) { Icon(Icons.Default.Add, null, modifier = Modifier.size(17.dp)) }
                    IconButton(
                        onClick = { viewModel.decreaseDraft(entry.id) },
                        modifier = Modifier.size(34.dp)
                    ) { Icon(Icons.Default.Remove, null, modifier = Modifier.size(17.dp)) }
                }
            }
        }
    }
}

@Composable
private fun HollowScreen(viewModel: AppViewModel, modifier: Modifier) {
    var outer by rememberSaveable { mutableStateOf("45") }
    var inner by rememberSaveable { mutableStateOf("12") }
    var length by rememberSaveable { mutableStateOf("4.0") }
    var quantity by rememberSaveable { mutableStateOf("1") }
    val values = listOf(outer.toDoubleOrNull(), inner.toDoubleOrNull(), length.toDoubleOrNull())
    val valid = values.all { it != null && it > 0 } && (values[0] ?: 0.0) > (values[1] ?: 0.0)
    val result = if (valid) viewModel.calculateHollow(values[0]!!, values[1]!!, values[2]!!) else null

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name))
        LazyColumn(
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Column(
                    Modifier
                        .fillMaxWidth()
                        .background(
                            Brush.linearGradient(listOf(KubajPrimary, KubajPrimaryEnd)),
                            RoundedCornerShape(24.dp)
                        )
                        .padding(28.dp)
                ) {
                    Text(
                        stringResource(R.string.net_volume).substringBefore(":").uppercase(),
                        color = Color.White.copy(alpha = 0.8f),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        "${volumeFormat.format(result?.netVolumeM3 ?: 0.0)} m³",
                        color = Color.White,
                        fontSize = 38.sp,
                        fontWeight = FontWeight.Black
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        stringResource(
                            R.string.equivalent_diameter,
                            result?.equivalentDiameterCm ?: 0
                        ),
                        color = Color.White.copy(alpha = 0.86f),
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
            item {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(184.dp)
                        .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(24.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Box(
                        Modifier
                            .size(126.dp)
                            .border(12.dp, Color(0xFFADC6FF), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            Modifier
                                .size(52.dp)
                                .border(2.dp, KubajPrimary, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Default.DonutLarge, null, tint = KubajPrimary)
                        }
                    }
                }
            }
            item {
                Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                    NumberField(stringResource(R.string.outer_diameter), outer, { outer = it })
                    NumberField(stringResource(R.string.length_m), length, { length = it })
                    NumberField(stringResource(R.string.inner_diameter), inner, { inner = it })
                    NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, integer = true)
                }
            }
            item {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    FilledTonalButton(
                        enabled = result != null,
                        onClick = {
                            result?.let {
                                viewModel.addEquivalentDiameter(
                                    it.equivalentDiameterCm - 1,
                                    values[2]!!,
                                    quantity.toIntOrNull() ?: 1
                                )
                            }
                        },
                        modifier = Modifier.weight(1f)
                    ) { Text("-1 DIA", fontSize = 11.sp) }
                    Button(
                        enabled = valid,
                        onClick = {
                            viewModel.addHollow(
                                values[0]!!,
                                values[1]!!,
                                values[2]!!,
                                quantity.toIntOrNull() ?: 1
                            )
                        },
                        modifier = Modifier.weight(1f)
                    ) { Text(stringResource(R.string.add_to_list), fontSize = 11.sp, maxLines = 1) }
                    FilledTonalButton(
                        enabled = result != null,
                        onClick = {
                            result?.let {
                                viewModel.addEquivalentDiameter(
                                    it.equivalentDiameterCm + 1,
                                    values[2]!!,
                                    quantity.toIntOrNull() ?: 1
                                )
                            }
                        },
                        modifier = Modifier.weight(1f)
                    ) { Text("+1 DIA", fontSize = 11.sp) }
                }
            }
        }
    }
}

@Composable
private fun SaveDialog(folders: List<FolderEntity>, viewModel: AppViewModel, onDismiss: () -> Unit) {
    var name by rememberSaveable { mutableStateOf("") }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(stringResource(R.string.select_file)) },
        text = {
            Column {
                folders.forEach { folder ->
                    Text(
                        folderPath(folder, folders),
                        Modifier
                            .fillMaxWidth()
                            .clickable { viewModel.saveDrafts(folder.id); onDismiss() }
                            .padding(12.dp)
                    )
                }
                OutlinedTextField(name, { name = it }, label = { Text(stringResource(R.string.file_name)) })
            }
        },
        confirmButton = {
            TextButton(onClick = {
                viewModel.createFolder(name) { viewModel.saveDrafts(it) }
                onDismiss()
            }) { Text(stringResource(R.string.create_file)) }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text(stringResource(R.string.cancel)) } }
    )
}

@Composable
private fun GroupingScreen(state: AppUiState, viewModel: AppViewModel, modifier: Modifier) {
    val context = LocalContext.current
    var folderMenu by remember { mutableStateOf(false) }
    var exportType by remember { mutableStateOf<String?>(null) }
    var deleteConfirm by remember { mutableStateOf(false) }
    val groups = if (state.selectedFolderId == null) {
        LogGrouping.sort(
            state.drafts.groupBy { it.lengthM to it.diameterCm }.map { (key, drafts) ->
                com.kubaj.android.domain.LogGroup(
                    "${key.first}-${key.second}",
                    key.second,
                    key.first,
                    drafts.sumOf { it.quantity },
                    drafts.sumOf { it.totalVolumeM3 },
                    emptyList()
                )
            },
            state.sortAscending
        )
    } else state.groups

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name)) {
            IconButton(enabled = groups.isNotEmpty(), onClick = { exportType = "pdf" }) {
                Icon(Icons.Default.Description, null)
            }
            IconButton(enabled = groups.isNotEmpty(), onClick = { exportType = "xlsx" }) {
                Icon(Icons.Default.TableView, null)
            }
            IconButton(enabled = state.selectedFolder != null, onClick = { deleteConfirm = true }) {
                Icon(Icons.Default.Delete, null, tint = KubajDanger)
            }
        }
        LazyColumn(
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(
                        stringResource(R.string.tab_grouping).uppercase(),
                        color = MaterialTheme.colorScheme.primary,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        stringResource(R.string.calculations),
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        stringResource(R.string.grouping_empty),
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            item {
                Box {
                    FilledTonalButton(onClick = { folderMenu = true }, modifier = Modifier.fillMaxWidth()) {
                        Text(state.selectedFolder?.name ?: stringResource(R.string.active_session))
                    }
                    DropdownMenu(folderMenu, { folderMenu = false }) {
                        DropdownMenuItem(
                            text = { Text(stringResource(R.string.active_session)) },
                            onClick = { viewModel.selectFolder(null); folderMenu = false }
                        )
                        state.folders.forEach {
                            DropdownMenuItem(
                                text = { Text(folderPath(it, state.folders)) },
                                onClick = { viewModel.selectFolder(it.id); folderMenu = false }
                            )
                        }
                    }
                }
            }
            item {
                val count = groups.sumOf { it.totalQuantity }
                GroupOverview(
                    totalVolume = groups.sumOf { it.totalVolumeM3 },
                    groupCount = groups.size,
                    averageDiameter = groups.takeIf { it.isNotEmpty() && count > 0 }
                        ?.let { values ->
                            values.sumOf { it.diameterCm * it.totalQuantity } / count
                        } ?: 0.0,
                    productCount = count
                )
            }
            item {
                TextButton(onClick = viewModel::toggleSort) {
                    Text("${stringResource(R.string.table_length)} ${if (state.sortAscending) "↑" else "↓"}")
                }
            }
            if (groups.isEmpty()) item { EmptyState(stringResource(R.string.grouping_empty)) }
            else item {
                GroupTable(
                    groups,
                    onIncrease = {
                        if (state.selectedFolderId == null) viewModel.increaseDraftGroup(it)
                        else viewModel.increaseGroup(it)
                    },
                    onDecrease = {
                        if (state.selectedFolderId == null) viewModel.decreaseDraftGroup(it)
                        else viewModel.decreaseGroup(it)
                    },
                    onDelete = {
                        if (state.selectedFolderId == null) viewModel.deleteDraftGroup(it)
                        else viewModel.deleteGroup(it)
                    }
                )
            }
        }
    }

    exportType?.let { type ->
        ExportDialog(type, groups, onDismiss = { exportType = null }) { fileName, metadata ->
            val file = if (type == "pdf") {
                Exporters.createPdf(context, fileName, groups, metadata)
            } else {
                Exporters.createXlsx(context, fileName, groups)
            }
            Exporters.share(
                context,
                file,
                if (type == "pdf") "application/pdf"
                else "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
            exportType = null
        }
    }
    if (deleteConfirm) ConfirmDialog(
        onDismiss = { deleteConfirm = false },
        onConfirm = {
            state.selectedFolder?.let(viewModel::deleteFolder)
            deleteConfirm = false
        }
    )
}

@Composable
private fun ExportDialog(
    type: String,
    groups: List<com.kubaj.android.domain.LogGroup>,
    onDismiss: () -> Unit,
    onExport: (String, ExportMetadata) -> Unit
) {
    var fileName by rememberSaveable { mutableStateOf("kubaj") }
    var company by rememberSaveable { mutableStateOf("") }
    var date by rememberSaveable { mutableStateOf("") }
    var location by rememberSaveable { mutableStateOf("") }
    var reporter by rememberSaveable { mutableStateOf("") }
    var code by rememberSaveable { mutableStateOf("") }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (type == "pdf") stringResource(R.string.export_pdf) else stringResource(R.string.export_excel)) },
        text = {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                item { OutlinedTextField(fileName, { fileName = it }, label = { Text(stringResource(R.string.export_file_name)) }) }
                item { OutlinedTextField(company, { company = it }, label = { Text(stringResource(R.string.company_name)) }) }
                item { OutlinedTextField(date, { date = it }, label = { Text(stringResource(R.string.report_date)) }) }
                item { OutlinedTextField(location, { location = it }, label = { Text(stringResource(R.string.location)) }) }
                item { OutlinedTextField(reporter, { reporter = it }, label = { Text(stringResource(R.string.reporter)) }) }
                item { OutlinedTextField(code, { code = it }, label = { Text(stringResource(R.string.project_code)) }) }
            }
        },
        confirmButton = {
            TextButton(
                enabled = groups.isNotEmpty(),
                onClick = { onExport(fileName, ExportMetadata(listOf(company, date, location, reporter, code))) }
            ) { Text(if (type == "pdf") stringResource(R.string.export_pdf) else stringResource(R.string.export_excel)) }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text(stringResource(R.string.cancel)) } }
    )
}

@Composable
private fun FoldersScreen(state: AppUiState, viewModel: AppViewModel, modifier: Modifier) {
    var name by rememberSaveable { mutableStateOf("") }
    var parentForNew by remember { mutableStateOf<FolderEntity?>(null) }
    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name))
        LazyColumn(
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    OutlinedTextField(
                        name,
                        { name = it },
                        label = { Text(stringResource(R.string.file_name)) },
                        modifier = Modifier.weight(1f)
                    )
                    IconButton(onClick = { viewModel.createFolder(name); name = "" }) {
                        Icon(Icons.Default.Add, null)
                    }
                }
            }
            val usedFolderIds = state.records.map { it.folderId }.toSet()
            val visible = state.folders.filter { it.id in usedFolderIds }
            if (visible.isEmpty()) item { EmptyState(stringResource(R.string.folders_empty)) }
            items(visible, key = { it.id }) { folder ->
                Card(
                    Modifier
                        .fillMaxWidth()
                        .clickable { viewModel.selectFolder(folder.id) }
                ) {
                    Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Folder, null, tint = MaterialTheme.colorScheme.primary)
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(folderPath(folder, state.folders), fontWeight = FontWeight.Bold)
                            Text("${state.records.count { it.folderId == folder.id }} ${stringResource(R.string.product_count)}")
                        }
                        IconButton(onClick = { parentForNew = folder }) {
                            Icon(Icons.Default.Add, null)
                        }
                        IconButton(onClick = { viewModel.deleteFolder(folder) }) {
                            Icon(Icons.Default.Delete, null, tint = KubajDanger)
                        }
                    }
                }
            }
        }
    }
    parentForNew?.let { parent ->
        var childName by rememberSaveable(parent.id) { mutableStateOf("") }
        AlertDialog(
            onDismissRequest = { parentForNew = null },
            title = { Text("${parent.name} / ${stringResource(R.string.create_file)}") },
            text = {
                OutlinedTextField(
                    childName,
                    { childName = it },
                    label = { Text(stringResource(R.string.file_name)) }
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.createFolder(childName, parent.id)
                    parentForNew = null
                }) { Text(stringResource(R.string.confirm)) }
            },
            dismissButton = {
                TextButton(onClick = { parentForNew = null }) {
                    Text(stringResource(R.string.cancel))
                }
            }
        )
    }
}

@Composable
private fun SettingsScreen(state: AppUiState, viewModel: AppViewModel, modifier: Modifier) {
    val context = LocalContext.current
    var exportType by remember { mutableStateOf<String?>(null) }
    val groups = if (state.selectedFolderId == null) {
        LogGrouping.sort(
            state.drafts.groupBy { it.lengthM to it.diameterCm }.map { (key, drafts) ->
                com.kubaj.android.domain.LogGroup(
                    "${key.first}-${key.second}",
                    key.second,
                    key.first,
                    drafts.sumOf { it.quantity },
                    drafts.sumOf { it.totalVolumeM3 },
                    emptyList()
                )
            },
            state.sortAscending
        )
    } else state.groups

    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.app_name))
        LazyColumn(
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 28.dp),
            verticalArrangement = Arrangement.spacedBy(28.dp)
        ) {
            item {
                SettingsSection(stringResource(R.string.tab_settings)) {
                    Row(
                        Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.Settings, null, tint = MaterialTheme.colorScheme.primary)
                        Spacer(Modifier.width(12.dp))
                        Text(stringResource(R.string.settings_haptics), Modifier.weight(1f))
                        Switch(state.preferences.hapticsEnabled, viewModel::setHaptics)
                    }
                }
            }
            item {
                SettingsSection(stringResource(R.string.settings_calculation_methods)) {
                    CalculationMethod.entries.forEach { method ->
                        SettingChoice(
                            text = when (method) {
                                CalculationMethod.HUBER -> stringResource(R.string.formula_huber)
                                CalculationMethod.SMALIAN -> stringResource(R.string.formula_smalian)
                                CalculationMethod.NEWTON -> stringResource(R.string.formula_newton)
                            },
                            selected = state.preferences.calculationMethod == method,
                            onClick = { viewModel.setMethod(method) }
                        )
                    }
                }
            }
            item {
                SettingsSection(stringResource(R.string.settings_theme)) {
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
                            onClick = { viewModel.setTheme(theme) }
                        )
                    }
                }
            }
            item {
                SettingsSection(stringResource(R.string.settings_language)) {
                    listOf("", "tr", "en", "de", "es", "pt", "fr", "sv", "fi", "ru").forEach { language ->
                        SettingChoice(
                            text = if (language.isEmpty()) stringResource(R.string.theme_system) else language.uppercase(),
                            selected = state.preferences.language == language,
                            onClick = { viewModel.setLanguage(language) }
                        )
                    }
                }
            }
            item {
                SettingsSection(stringResource(R.string.export_settings)) {
                    Column(
                        Modifier.padding(12.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        DataExportCard(
                            icon = Icons.Default.Description,
                            title = stringResource(R.string.export_pdf),
                            enabled = groups.isNotEmpty()
                        ) { exportType = "pdf" }
                        DataExportCard(
                            icon = Icons.Default.TableView,
                            title = stringResource(R.string.export_excel),
                            enabled = groups.isNotEmpty()
                        ) { exportType = "xlsx" }
                    }
                }
            }
            item { FolderSettings(state, viewModel) }
            item {
                Text(
                    "WOODLOG V${com.kubaj.android.BuildConfig.VERSION_NAME}",
                    Modifier.fillMaxWidth(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.65f),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            }
        }
    }

    exportType?.let { type ->
        ExportDialog(type, groups, onDismiss = { exportType = null }) { fileName, metadata ->
            val file = if (type == "pdf") {
                Exporters.createPdf(context, fileName, groups, metadata)
            } else {
                Exporters.createXlsx(context, fileName, groups)
            }
            Exporters.share(
                context,
                file,
                if (type == "pdf") "application/pdf"
                else "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
            exportType = null
        }
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
                    if (MaterialTheme.colorScheme.background == Color(0xFFF9F9F9)) Color(0xFFF3F3F3)
                    else MaterialTheme.colorScheme.surface,
                    RoundedCornerShape(24.dp)
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
                else MaterialTheme.colorScheme.surface,
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
private fun DataExportCard(
    icon: ImageVector,
    title: String,
    enabled: Boolean,
    onClick: () -> Unit
) {
    Column(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(20.dp))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Box(
            Modifier
                .size(44.dp)
                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.10f), RoundedCornerShape(14.dp)),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, tint = MaterialTheme.colorScheme.primary)
        }
        Text(title, fontWeight = FontWeight.Bold)
        FilledTonalButton(onClick = onClick, enabled = enabled, modifier = Modifier.fillMaxWidth()) {
            Text(title)
        }
    }
}

@Composable
private fun FolderSettings(state: AppUiState, viewModel: AppViewModel) {
    var name by rememberSaveable { mutableStateOf("") }
    SettingsSection(stringResource(R.string.tab_folders)) {
        Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                OutlinedTextField(
                    name,
                    { name = it },
                    label = { Text(stringResource(R.string.file_name)) },
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
                IconButton(
                    enabled = name.isNotBlank(),
                    onClick = { viewModel.createFolder(name); name = "" }
                ) { Icon(Icons.Default.Add, null) }
            }
            state.folders.forEach { folder ->
                Row(
                    Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
                        .clickable { viewModel.selectFolder(folder.id) }
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Folder, null, tint = MaterialTheme.colorScheme.primary)
                    Spacer(Modifier.width(10.dp))
                    Text(folderPath(folder, state.folders), Modifier.weight(1f), fontWeight = FontWeight.SemiBold)
                    IconButton(onClick = { viewModel.deleteFolder(folder) }) {
                        Icon(Icons.Default.Delete, null, tint = KubajDanger)
                    }
                }
            }
        }
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
