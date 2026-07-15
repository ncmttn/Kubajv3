package com.kubaj.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
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
import androidx.compose.ui.platform.LocalHapticFeedback
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
fun SummaryCards(totalVolume: Double, count: Int, averageDiameter: Double) {
    Row(
        Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        SummaryCard(
            stringResource(R.string.total_volume),
            "${volumeFormat.format(totalVolume)} m³",
            Modifier.weight(1f)
        )
        SummaryCard(
            stringResource(R.string.product_count),
            count.toString(),
            Modifier.weight(1f)
        )
        SummaryCard(
            stringResource(R.string.average_diameter),
            "${diameterFormat.format(averageDiameter)} cm",
            Modifier.weight(1f)
        )
    }
}

@Composable
fun HomeStatsCard(
    totalVolume: Double,
    count: Int,
    averageDiameter: Double,
    onReset: () -> Unit
) {
    Column(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(24.dp))
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(verticalAlignment = Alignment.Top) {
            Column(Modifier.weight(1f)) {
                Text(
                    stringResource(R.string.total_volume).uppercase(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 2.sp
                )
                Text(
                    "${volumeFormat.format(totalVolume)} m³",
                    color = MaterialTheme.colorScheme.primary,
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Black,
                    maxLines = 1
                )
            }
            IconButton(
                onClick = onReset,
                modifier = Modifier
                    .size(40.dp)
                    .background(MaterialTheme.colorScheme.surfaceVariant, CircleShape)
            ) {
                Icon(Icons.Default.Refresh, null, modifier = Modifier.size(18.dp))
            }
        }
        Box(
            Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(MaterialTheme.colorScheme.outlineVariant)
        )
        Row(horizontalArrangement = Arrangement.spacedBy(32.dp)) {
            HomeStatBlock(stringResource(R.string.product_count), count.toString(), Modifier.weight(1f))
            HomeStatBlock(
                stringResource(R.string.average_diameter),
                "${diameterFormat.format(averageDiameter)} cm",
                Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun HomeStatBlock(title: String, value: String, modifier: Modifier) {
    Column(modifier) {
        Text(
            title.uppercase(),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.sp
        )
        Text(value, fontSize = 20.sp, fontWeight = FontWeight.Bold, maxLines = 1)
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
        TableHeader(sortAscending, onToggleSort)
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
                Text((index + 1).toString(), Modifier.width(28.dp), fontWeight = FontWeight.SemiBold, textAlign = TextAlign.Center)
                Text(lengthFormat.format(group.lengthM), Modifier.width(44.dp), textAlign = TextAlign.Center)
                Text(group.totalQuantity.toString(), Modifier.width(36.dp), textAlign = TextAlign.Center)
                Text(diameterFormat.format(group.diameterCm), Modifier.width(42.dp), textAlign = TextAlign.Center)
                Text(
                    volumeFormat.format(group.totalVolumeM3),
                    Modifier.width(56.dp),
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
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
private fun TableHeader(sortAscending: Boolean, onToggleSort: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.65f))
            .padding(horizontal = 10.dp, vertical = 11.dp)
    ) {
        Text(stringResource(R.string.table_no), Modifier.width(28.dp), fontSize = 9.sp, textAlign = TextAlign.Center)
        Text(
            "${stringResource(R.string.table_length)} ${if (sortAscending) "↑" else "↓"}",
            Modifier
                .width(44.dp)
                .clickable(onClick = onToggleSort),
            fontSize = 9.sp,
            textAlign = TextAlign.Center
        )
        Text(stringResource(R.string.table_quantity), Modifier.width(36.dp), fontSize = 9.sp, textAlign = TextAlign.Center)
        Text(stringResource(R.string.table_diameter), Modifier.width(42.dp), fontSize = 9.sp, textAlign = TextAlign.Center)
        Text(stringResource(R.string.table_volume), Modifier.width(56.dp), fontSize = 9.sp, textAlign = TextAlign.Center)
        Spacer(Modifier.width(84.dp))
    }
}

@Composable
private fun SmallAction(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    tint: Color = MaterialTheme.colorScheme.primary,
    hapticsEnabled: Boolean,
    action: () -> Unit
) {
    val haptic = LocalHapticFeedback.current
    IconButton(
        onClick = {
            if (hapticsEnabled) {
                haptic.performHapticFeedback(androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress)
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
