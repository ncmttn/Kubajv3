package com.kubaj.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.kubaj.android.R
import com.kubaj.android.domain.LogEntryDisplay
import com.kubaj.android.domain.LogGroup
import com.kubaj.android.domain.LogGrouping
import java.text.DecimalFormat
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collect

val volumeFormat = DecimalFormat("0.000")
val lengthFormat = DecimalFormat("0.0")
val diameterFormat = DecimalFormat("0")

@Composable
fun NumberField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    integer: Boolean = false,
    focusRequester: FocusRequester? = null,
    selectAllTrigger: Int = 0,
    trailing: @Composable (() -> Unit)? = null
) {
    var fieldValue by remember { mutableStateOf(TextFieldValue(value)) }
    var wasFocused by remember { mutableStateOf(false) }
    val interactionSource = remember { MutableInteractionSource() }

    LaunchedEffect(value) {
        if (fieldValue.text != value) {
            fieldValue = TextFieldValue(value, TextRange(value.length))
        }
    }
    LaunchedEffect(selectAllTrigger) {
        if (selectAllTrigger > 0) {
            fieldValue = fieldValue.copy(selection = TextRange(0, fieldValue.text.length))
        }
    }
    LaunchedEffect(interactionSource) {
        interactionSource.interactions.collect { interaction ->
            if (interaction is PressInteraction.Release) {
                delay(30)
                fieldValue = fieldValue.copy(selection = TextRange(0, fieldValue.text.length))
            }
        }
    }

    Column(modifier) {
        Text(
            text = label.uppercase(),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(start = 8.dp, bottom = 6.dp)
        )
        OutlinedTextField(
            value = fieldValue,
            onValueChange = {
                fieldValue = it
                onValueChange(it.text)
            },
            modifier = Modifier
                .fillMaxWidth()
                .then(if (focusRequester != null) Modifier.focusRequester(focusRequester) else Modifier)
                .onFocusChanged { state ->
                    if (state.isFocused && !wasFocused) {
                        fieldValue = fieldValue.copy(selection = TextRange(0, fieldValue.text.length))
                    }
                    wasFocused = state.isFocused
                },
            singleLine = true,
            shape = RoundedCornerShape(12.dp),
            textStyle = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Bold),
            keyboardOptions = KeyboardOptions(
                keyboardType = if (integer) KeyboardType.Number else KeyboardType.Decimal
            ),
            trailingIcon = trailing,
            interactionSource = interactionSource,
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
                focusedBorderColor = Color.Transparent,
                unfocusedBorderColor = Color.Transparent
            )
        )
    }
}

@Composable
fun HomeStatsCard(
    totalVolume: Double,
    count: Int,
    onReset: () -> Unit
) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(24.dp))
            .padding(horizontal = 18.dp, vertical = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        HomeStatBlock(
            stringResource(R.string.total_volume),
            "${volumeFormat.format(totalVolume)} m³",
            Modifier.weight(1.7f),
            valueColor = MaterialTheme.colorScheme.primary
        )
        HomeStatBlock(
            stringResource(R.string.product_count),
            count.toString(),
            Modifier.weight(0.8f)
        )
        IconButton(
            onClick = onReset,
            modifier = Modifier
                .size(40.dp)
                .background(MaterialTheme.colorScheme.surfaceVariant, CircleShape)
        ) {
            Icon(Icons.Default.Refresh, null, modifier = Modifier.size(18.dp))
        }
    }
}

@Composable
private fun HomeStatBlock(
    title: String,
    value: String,
    modifier: Modifier,
    valueColor: Color = MaterialTheme.colorScheme.onSurface
) {
    Column(modifier) {
        Text(
            title.uppercase(),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.sp
        )
        Text(
            value,
            color = valueColor,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
fun GroupOverview(
    totalVolume: Double,
    productCount: Int
) {
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        SummaryCard(
            stringResource(R.string.total_volume),
            "${volumeFormat.format(totalVolume)} m³",
            Modifier.weight(1f)
        )
        SummaryCard(
            stringResource(R.string.product_count),
            productCount.toString(),
            Modifier.weight(1f)
        )
    }
}

@Composable
private fun SummaryCard(title: String, value: String, modifier: Modifier) {
    Column(
        modifier = modifier
            .background(MaterialTheme.colorScheme.surfaceContainerLowest, RoundedCornerShape(12.dp))
            .padding(horizontal = 16.dp, vertical = 18.dp)
    ) {
        Text(
            title.uppercase(),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
        Spacer(Modifier.height(4.dp))
        Text(
            value,
            color = MaterialTheme.colorScheme.primary,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
fun GroupTable(
    groups: List<LogGroup>,
    sortAscending: Boolean,
    onToggleSort: () -> Unit,
    hapticsEnabled: Boolean,
    onIncrease: (LogGroup) -> Unit,
    onDecrease: (LogGroup) -> Unit,
    onDelete: (LogGroup) -> Unit
) {
    val bands = LogGrouping.lengthBands(groups.map { it.lengthM })
    Column(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
    ) {
        GroupTableHeader(sortAscending, onToggleSort)
        groups.forEachIndexed { index, group ->
            val tint = if (bands[index] == 1) {
                MaterialTheme.colorScheme.primary.copy(alpha = 0.055f)
            } else {
                Color.Transparent
            }
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(tint)
                    .padding(horizontal = 10.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                TableValue((index + 1).toString(), Modifier.weight(0.45f))
                TableValue(lengthFormat.format(group.lengthM), Modifier.weight(0.7f))
                TableValue(group.totalQuantity.toString(), Modifier.weight(0.6f))
                TableValue(LogEntryDisplay.diameterLabel(group), Modifier.weight(0.85f))
                Text(
                    volumeFormat.format(group.totalVolumeM3),
                    Modifier.weight(0.9f),
                    color = MaterialTheme.colorScheme.primary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    maxLines = 1
                )
                Row(Modifier.width(84.dp)) {
                    SmallAction(Icons.Default.Add, hapticsEnabled = hapticsEnabled) { onIncrease(group) }
                    SmallAction(Icons.Default.Remove, hapticsEnabled = hapticsEnabled) { onDecrease(group) }
                    SmallAction(Icons.Default.Delete, KubajDanger, hapticsEnabled) { onDelete(group) }
                }
            }
        }
    }
}

@Composable
fun GroupTableHeader(sortAscending: Boolean, onToggleSort: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.65f))
            .padding(horizontal = 10.dp, vertical = 12.dp)
    ) {
        TableTitle(stringResource(R.string.table_no), Modifier.weight(0.45f))
        TableTitle(
            "${stringResource(R.string.table_length)} ${if (sortAscending) "↑" else "↓"}",
            Modifier
                .weight(0.7f)
                .clickable(onClick = onToggleSort)
        )
        TableTitle(stringResource(R.string.table_quantity), Modifier.weight(0.6f))
        TableTitle(stringResource(R.string.table_diameter), Modifier.weight(0.85f))
        TableTitle(stringResource(R.string.table_volume), Modifier.weight(0.9f))
        Spacer(Modifier.width(84.dp))
    }
}

@Composable
fun RowScope.TableTitle(text: String, modifier: Modifier) {
    Text(
        text.uppercase(),
        modifier,
        fontSize = 11.sp,
        fontWeight = FontWeight.Bold,
        textAlign = TextAlign.Center,
        maxLines = 1,
        overflow = TextOverflow.Ellipsis
    )
}

@Composable
fun RowScope.TableValue(text: String, modifier: Modifier) {
    Text(
        text,
        modifier,
        fontSize = 13.sp,
        fontWeight = FontWeight.Medium,
        textAlign = TextAlign.Center,
        maxLines = 1,
        overflow = TextOverflow.Ellipsis
    )
}

@Composable
private fun TableHeader(sortAscending: Boolean, onToggleSort: () -> Unit) {
    GroupTableHeader(sortAscending, onToggleSort)
}

@Composable
private fun SmallAction(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    tint: Color = MaterialTheme.colorScheme.primary,
    hapticsEnabled: Boolean,
    action: () -> Unit
) {
    val context = LocalContext.current
    IconButton(
        onClick = {
            if (hapticsEnabled) {
                performAppHaptic(context)
            }
            action()
        },
        modifier = Modifier.width(28.dp)
    ) {
        Icon(icon, null, tint = tint)
    }
}

@Composable
fun EmptyState(text: String) {
    Box(
        Modifier
            .fillMaxWidth()
            .padding(vertical = 40.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
