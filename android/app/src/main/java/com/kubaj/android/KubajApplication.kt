package com.kubaj.android

import android.app.Application
import com.kubaj.android.data.AppPreferences
import com.kubaj.android.data.KubajDatabase

class KubajApplication : Application() {
    val database by lazy { KubajDatabase.create(this) }
    val preferences by lazy { AppPreferences(this) }
}
