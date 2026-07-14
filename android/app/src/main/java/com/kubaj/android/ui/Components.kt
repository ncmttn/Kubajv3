package com.kubaj.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.kubaj.android.R
import com.kubaj.android.domain.LogGroup
import com.kubaj.android.domain.LogGrouping
import java.text.DecimalFormat

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
    trailing: @Composable (() -> Unit)? = null
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = {
            Text(
                text = label.uppercase(),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold
            )
        },
        modifier = modifier,
        singleLine = true,
        shape = RoundedCornerShape(14.dp),
        keyboardOptions = KeyboardOptions(
            keyboardType = if (integer) KeyboardType.Number else KeyboardType.Decimal
        ),
        trailingIcon = trailing
    )
}

@Composable
fun SummaryCards(totalVolume: Double, count: Int, averageDiameter: Double) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
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
    }
    Spacer(Modifier.height(12.dp))
    SummaryCard(
        stringResource(R.string.average_diameter),
        "${diameterFormat.format(averageDiameter)} cm",
        Modifier.fillMaxWidth()
    )
}

@Composable
private fun SummaryCard(title: String, value: String, modifier: Modifier) {
    Column(
        modifier = modifier
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(18.dp))
            .padding(18.dp)
    ) {
        Text(
            title.uppercase(),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold
        )
        Text(value, fontSize = 23.sp, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun GroupTable(
    groups: List<LogGroup>,
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
        TableHeader()
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
                Text((index + 1).toString(), Modifier.width(28.dp), fontWeight = FontWeight.SemiBold)
                Text(lengthFormat.format(group.lengthM), Modifier.width(52.dp))
                Text(group.totalQuantity.toString(), Modifier.width(42.dp))
                Text(diameterFormat.format(group.diameterCm), Modifier.weight(1f))
                Text(
                    volumeFormat.format(group.totalVolumeM3),
                    Modifier.width(68.dp),
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
                Row(Modifier.width(96.dp)) {
                    SmallAction(Icons.Default.Add) { onIncrease(group) }
                    SmallAction(Icons.Default.Remove) { onDecrease(group) }
                    SmallAction(Icons.Default.Delete, KubajDanger) { onDelete(group) }
                }
            }
        }
    }
}

@Composable
private fun TableHeader() {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.65f))
            .padding(horizontal = 10.dp, vertical = 11.dp)
    ) {
        Text(stringResource(R.string.table_no), Modifier.width(28.dp))
        Text(stringResource(R.string.table_length), Modifier.width(52.dp))
        Text(stringResource(R.string.table_quantity), Modifier.width(42.dp))
        Text(stringResource(R.string.table_diameter), Modifier.weight(1f))
        Text(stringResource(R.string.table_volume), Modifier.width(68.dp))
        Spacer(Modifier.width(96.dp))
    }
}

@Composable
private fun SmallAction(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    tint: Color = MaterialTheme.colorScheme.primary,
    action: () -> Unit
) {
    val haptic = LocalHapticFeedback.current
    IconButton(
        onClick = {
            haptic.performHapticFeedback(androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress)
            action()
        },
        modifier = Modifier.width(32.dp)
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
