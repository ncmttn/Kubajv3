package com.kubaj.android.data

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Delete
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Entity(tableName = "folders")
data class FolderEntity(
    @androidx.room.PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val parentId: Long? = null,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(
    tableName = "log_records",
    foreignKeys = [
        ForeignKey(
            entity = FolderEntity::class,
            parentColumns = ["id"],
            childColumns = ["folderId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("folderId")]
)
data class LogRecordEntity(
    @androidx.room.PrimaryKey(autoGenerate = true) val id: Long = 0,
    val folderId: Long,
    val diameterCm: Double,
    val lengthM: Double,
    val quantity: Int,
    val volumeM3: Double,
    val calculationMethod: String,
    val isHollow: Boolean = false,
    val isLumber: Boolean = false,
    val topDiameterCm: Double? = null,
    val midDiameterCm: Double? = null,
    val buttDiameterCm: Double? = null,
    val lumberThicknessCm: Double? = null,
    val createdAt: Long = System.currentTimeMillis()
)

@Dao
interface KubajDao {
    @Query("SELECT * FROM folders ORDER BY createdAt, name")
    fun observeFolders(): Flow<List<FolderEntity>>

    @Query("SELECT * FROM log_records ORDER BY createdAt DESC")
    fun observeRecords(): Flow<List<LogRecordEntity>>

    @Insert
    suspend fun insertFolder(folder: FolderEntity): Long

    @Insert
    suspend fun insertRecords(records: List<LogRecordEntity>)

    @Update
    suspend fun updateRecord(record: LogRecordEntity)

    @Delete
    suspend fun deleteRecord(record: LogRecordEntity)

    @Delete
    suspend fun deleteFolder(folder: FolderEntity)

    @Query("DELETE FROM log_records WHERE id IN (:ids)")
    suspend fun deleteRecords(ids: List<Long>)
}

@Database(
    entities = [FolderEntity::class, LogRecordEntity::class],
    version = 1,
    exportSchema = true
)
abstract class KubajDatabase : RoomDatabase() {
    abstract fun dao(): KubajDao

    companion object {
        fun create(context: Context): KubajDatabase =
            Room.databaseBuilder(context, KubajDatabase::class.java, "kubaj.db")
                .fallbackToDestructiveMigration(false)
                .build()
    }
}
