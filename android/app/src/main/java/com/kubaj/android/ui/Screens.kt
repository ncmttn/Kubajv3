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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Inventory2
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
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
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
import com.kubaj.android.domain.CalculationMethod
import com.kubaj.android.domain.DraftEntry
import com.kubaj.android.domain.LogGrouping
import com.kubaj.android.export.ExportMetadata
import com.kubaj.android.export.Exporters
import kotlinx.coroutines.delay

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
        AppCompatDelegate.setApplicationLocales(
            LocaleListCompat.forLanguageTags(state.preferences.language)
        )
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
            .background(KubajPrimary),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                Modifier
                    .size(110.dp)
                    .background(Color.White, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.Calculate, null, tint = KubajPrimary, modifier = Modifier.size(56.dp))
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
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(Icons.Default.Inventory2, null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(110.dp))
        Spacer(Modifier.height(40.dp))
        Text(stringResource(titles[page]), fontSize = 34.sp, fontWeight = FontWeight.Black, textAlign = TextAlign.Center)
        Spacer(Modifier.height(14.dp))
        Text(stringResource(bodies[page]), textAlign = TextAlign.Center, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(36.dp))
        Button(onClick = { if (page == 2) onComplete() else page++ }, modifier = Modifier.fillMaxWidth()) {
            Text(stringResource(if (page == 2) R.string.get_started else R.string.next))
        }
    }
}

@Composable
private fun MainScreen(state: AppUiState, viewModel: AppViewModel) {
    var selected by rememberSaveable { mutableStateOf(MainTab.HOME) }
    Scaffold(
        bottomBar = {
            NavigationBar {
                MainTab.entries.forEach { tab ->
                    NavigationBarItem(
                        selected = selected == tab,
                        onClick = { selected = tab },
                        icon = { Icon(tab.icon, null) },
                        label = { Text(stringResource(tab.label), maxLines = 1, fontSize = 10.sp) }
                    )
                }
            }
        }
    ) { padding ->
        when (selected) {
            MainTab.HOME -> HomeScreen(state, viewModel, Modifier.padding(padding))
            MainTab.GROUPING -> GroupingScreen(state, viewModel, Modifier.padding(padding))
            MainTab.FOLDERS -> FoldersScreen(state, viewModel, Modifier.padding(padding))
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
        Icon(Icons.Default.Inventory2, null, tint = MaterialTheme.colorScheme.primary)
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
    var width by rememberSaveable { mutableStateOf("21") }
    var thickness by rememberSaveable { mutableStateOf("") }
    var length by rememberSaveable { mutableStateOf("") }
    var quantity by rememberSaveable { mutableStateOf("1") }
    var showHollow by rememberSaveable { mutableStateOf(false) }
    var showSave by rememberSaveable { mutableStateOf(false) }
    var clearConfirm by rememberSaveable { mutableStateOf(false) }

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
                            NumberField(stringResource(R.string.diameter_cm), diameter, { diameter = it }, Modifier.weight(1f)) {
                                TextButton(onClick = {
                                    diameter = ((diameter.toDoubleOrNull() ?: 21.0) + 1).toInt().toString()
                                }) { Text("+1") }
                            }
                            NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                        }
                        CalculationMethod.SMALIAN -> {
                            InputPair {
                                NumberField(stringResource(R.string.top_diameter_cm), top, { top = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.butt_diameter_cm), butt, { butt = it }, Modifier.weight(1f))
                            }
                            InputPair {
                                NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, Modifier.weight(1f), true)
                            }
                        }
                        CalculationMethod.NEWTON -> {
                            InputPair {
                                NumberField(stringResource(R.string.top_diameter_cm), top, { top = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.butt_diameter_cm), butt, { butt = it }, Modifier.weight(1f))
                            }
                            InputPair {
                                NumberField(stringResource(R.string.mid_diameter_cm), mid, { mid = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                            }
                        }
                        CalculationMethod.ULKER -> {
                            InputPair {
                                NumberField(stringResource(R.string.width_cm), width, { width = it }, Modifier.weight(1f))
                                NumberField(stringResource(R.string.thickness_cm), thickness, { thickness = it }, Modifier.weight(1f))
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
                    FilledTonalButton(onClick = { showHollow = true }, modifier = Modifier.weight(1f)) {
                        Text(stringResource(R.string.calculate_hollow), maxLines = 1)
                    }
                    Button(
                        onClick = {
                            viewModel.addStandard(
                                diameter.toDoubleOrNull(),
                                top.toDoubleOrNull(),
                                mid.toDoubleOrNull(),
                                butt.toDoubleOrNull(),
                                width.toDoubleOrNull(),
                                thickness.toDoubleOrNull(),
                                length.toDoubleOrNull(),
                                quantity.toIntOrNull()
                            )
                        },
                        modifier = Modifier.weight(1f)
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

    if (showHollow) HollowSheet(viewModel) { showHollow = false }
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
                Text(lengthFormat.format(entry.lengthM), Modifier.width(50.dp))
                Text(entry.quantity.toString(), Modifier.width(40.dp))
                Text(diameterFormat.format(entry.diameterCm), Modifier.weight(1f))
                Text(volumeFormat.format(entry.totalVolumeM3), color = MaterialTheme.colorScheme.primary)
                IconButton(onClick = { viewModel.increaseDraft(entry.id) }) { Icon(Icons.Default.Add, null) }
                IconButton(onClick = { viewModel.decreaseDraft(entry.id) }) { Icon(Icons.Default.Remove, null) }
                IconButton(onClick = { viewModel.deleteDraft(entry.id) }) { Icon(Icons.Default.Delete, null, tint = KubajDanger) }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun HollowSheet(viewModel: AppViewModel, onDismiss: () -> Unit) {
    var outer by rememberSaveable { mutableStateOf("") }
    var inner by rememberSaveable { mutableStateOf("") }
    var length by rememberSaveable { mutableStateOf("") }
    var quantity by rememberSaveable { mutableStateOf("1") }
    val values = listOf(outer.toDoubleOrNull(), inner.toDoubleOrNull(), length.toDoubleOrNull())
    val valid = values.all { it != null && it > 0 } && (values[0] ?: 0.0) > (values[1] ?: 0.0)
    val result = if (valid) viewModel.calculateHollow(values[0]!!, values[1]!!, values[2]!!) else null

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text(stringResource(R.string.calculate_hollow), fontSize = 22.sp, fontWeight = FontWeight.Bold)
            InputPair {
                NumberField(stringResource(R.string.outer_diameter), outer, { outer = it }, Modifier.weight(1f))
                NumberField(stringResource(R.string.inner_diameter), inner, { inner = it }, Modifier.weight(1f))
            }
            InputPair {
                NumberField(stringResource(R.string.length_m), length, { length = it }, Modifier.weight(1f))
                NumberField(stringResource(R.string.quantity), quantity, { quantity = it }, Modifier.weight(1f), true)
            }
            result?.let {
                Card(Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(16.dp)) {
                        Text(stringResource(R.string.equivalent_diameter, it.equivalentDiameterCm), fontWeight = FontWeight.Bold)
                        Text(stringResource(R.string.net_volume, it.netVolumeM3))
                    }
                }
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    FilledTonalButton(
                        onClick = {
                            viewModel.addEquivalentDiameter(it.equivalentDiameterCm - 1, values[2]!!, quantity.toIntOrNull() ?: 1)
                            onDismiss()
                        },
                        modifier = Modifier.weight(1f)
                    ) { Text(stringResource(R.string.add_diameter, it.equivalentDiameterCm - 1)) }
                    FilledTonalButton(
                        onClick = {
                            viewModel.addEquivalentDiameter(it.equivalentDiameterCm + 1, values[2]!!, quantity.toIntOrNull() ?: 1)
                            onDismiss()
                        },
                        modifier = Modifier.weight(1f)
                    ) { Text(stringResource(R.string.add_diameter, it.equivalentDiameterCm + 1)) }
                }
            }
            Button(
                enabled = valid,
                onClick = {
                    viewModel.addHollow(values[0]!!, values[1]!!, values[2]!!, quantity.toIntOrNull() ?: 1)
                    onDismiss()
                },
                modifier = Modifier.fillMaxWidth()
            ) { Text(stringResource(R.string.add_to_list)) }
            Spacer(Modifier.height(24.dp))
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
        ScreenHeader(stringResource(R.string.tab_grouping)) {
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
                SummaryCards(
                    groups.sumOf { it.totalVolumeM3 },
                    groups.sumOf { it.totalQuantity },
                    groups.takeIf { it.isNotEmpty() }
                        ?.let { values ->
                            values.sumOf { it.diameterCm * it.totalQuantity } / values.sumOf { it.totalQuantity }
                        } ?: 0.0
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
                    onIncrease = { if (it.records.isNotEmpty()) viewModel.increaseGroup(it) },
                    onDecrease = { if (it.records.isNotEmpty()) viewModel.decreaseGroup(it) },
                    onDelete = { if (it.records.isNotEmpty()) viewModel.deleteGroup(it) }
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
        ScreenHeader(stringResource(R.string.tab_folders))
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
    Column(modifier.fillMaxSize()) {
        ScreenHeader(stringResource(R.string.tab_settings))
        LazyColumn(
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp)
        ) {
            item {
                SettingsSection(stringResource(R.string.settings_calculation_methods)) {
                    CalculationMethod.entries.forEach { method ->
                        SettingChoice(
                            text = when (method) {
                                CalculationMethod.HUBER -> stringResource(R.string.formula_huber)
                                CalculationMethod.SMALIAN -> stringResource(R.string.formula_smalian)
                                CalculationMethod.NEWTON -> stringResource(R.string.formula_newton)
                                CalculationMethod.ULKER -> stringResource(R.string.formula_ulker)
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
                    listOf("tr", "en", "de", "es", "pt", "fr", "sv", "fi", "ru").forEach { language ->
                        SettingChoice(
                            text = language.uppercase(),
                            selected = state.preferences.language == language,
                            onClick = { viewModel.setLanguage(language) }
                        )
                    }
                }
            }
            item {
                Card(Modifier.fillMaxWidth()) {
                    Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(stringResource(R.string.settings_haptics), Modifier.weight(1f))
                        Switch(state.preferences.hapticsEnabled, viewModel::setHaptics)
                    }
                }
            }
        }
    }
}

@Composable
private fun SettingsSection(title: String, content: @Composable () -> Unit) {
    Column {
        Text(title.uppercase(), fontSize = 12.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(8.dp))
        Card(Modifier.fillMaxWidth()) {
            Column(Modifier.padding(vertical = 6.dp), content = { content() })
        }
    }
}

@Composable
private fun SettingChoice(text: String, selected: Boolean, onClick: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 7.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        RadioButton(selected, onClick)
        Text(text)
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
