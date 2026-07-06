# Kübaj 2.0 - Native Swift Ormancılık Hesaplama Uygulaması

## Proje Özeti
Kübaj 2.0, ormancılık sektöründe tomruk hacim hesaplamaları için geliştirilen "offline-first" bir iOS uygulamasıdır. Performansı maksimize etmek ve global pazara açılmak amacıyla Swift 5.9+ ve SwiftUI ile sıfırdan yazılmaktadır.

## Teknik Stack ve Mimari
- **Platform:** iOS 17.0+
- **Arayüz:** SwiftUI (Native bileşenler + Glassmorphism detaylar)
- **Veri Tabanı:** SwiftData
- **Mimari Desen:** MVVM (Model-View-ViewModel) + `@Observable` makrosu
- **Yerelleştirme (i18n):** String Catalogs (.xcstrings)
- **Dışa Aktarım (Export):** PDFKit (Native PDF üretimi) ve CSV/Excel
- **Dokümantasyon Standardı:** Kod içi yorum satırları KESİNLİKLE kullanılmayacaktır. Temiz kod (Clean Code) prensibi geçerlidir. Tüm yapısal açıklamalar GitHub Commit/Issue olarak tutulacaktır.

## Yerelleştirme (Çoklu Dil) Stratejisi
Global ormancılık faaliyetleri baz alınarak; Türkçe, İngilizce, Rusça, Almanca, İspanyolca, Portekizce, Fransızca, İsveççe ve Fince dilleri desteklenecektir.
- UI bileşenleri, alert/uyarı mesajları ve PDF/Excel çıktı tablolarının tamamı seçilen dile göre dinamik olarak render edilmelidir.

## Veri Hiyerarşisi ve Modeller (SwiftData)
Sistem esnek ve iç içe geçebilen (nested) 2 ana relational modelden oluşur:
1. **Folder (Klasör):** Kullanıcının serbestçe isimlendirdiği klasörlerdir. Kendi içinde alt klasörler (subFolders) barındırabilir ve bir üst klasöre (parentFolder) bağlanabilir.
2. **LogRecord (Tomruk Kaydı):** Bireysel hesaplama satırıdır. Her kayıt bir Folder'a aittir.
   - Özellikler: Çap (cm), Boy (m), Adet, Hacim (m³), Hesaplama Yöntemi (Enum), isHollow (Kovuklu mu? Boolean).

## Hesaplama Motoru (Forestry Calculator)
Hesaplama işlemleri arayüzden bağımsız bir Domain servisi olarak yazılacaktır.
- **Kullanılacak Formüller:** Smalian, Huber (Varsayılan), Newton.
- Kullanıcı ayarlardan varsayılan formülü seçer.

## Kullanıcı Akışı ve Ekranlar

### 1. Ana Hesaplama Ekranı (Home View)
- Hızlı veri girişi (Çap, Boy, Adet) yapılır.
- **Sıralama:** En son eklenen en üstte görünür (`id DESC`).
- **Kovuk Hesaplama:** Ayrı bir "Kovuk Hesapla" butonu/modalı ile yapılır. Dış çap ve iç çap (kovuk) girilip net hacim hesaplanır. Bulunan "Eşdeğer Katı Çap" ile tomruk ana listeye (isHollow = true) eklenir.
- **Kaydetme Akışı:** Liste uzar, kullanıcı "Kaydet" dediğinde verileri hangi "Bölme > İstif" altına kaydedeceğini seçer.
- Swipe Actions: Sağa/sola kaydırarak adet artırma/azaltma ve silme işlemleri native ve haptic feedback ile yapılır.

### 2. Gruplandırma Ekranı (Grouping View)
- Aynı Çap ve Boy değerlerine sahip verilerin birleştirilip toplamlarının gösterildiği ekran.
- **Özel Yetenek:** Bu özet ekranda adet artırma/azaltma veya o grubu silme işlemi yapılabilir. Yapılan değişiklik ham veriyi de (LogRecord) güncellemeli (Batch update).
- **Sıralama:** Çap değerine göre Sorting (Sıralama) yapılabilmelidir.

### 3. Dışa Aktarma Akışı (Export / PDF)
- Sadece "Gruplandırılmış" veriler dışa aktarılır.
- Tablo Başlığı sabit olarak "Ebat Listesi" (seçili dile çevrilmiş haliyle) olmalıdır.
- **Pre-Export Modal:** PDF oluşturulmadan önce açılan opsiyonel bir form. Kullanıcının rapora yansıtması için maks. 5 adet zorunlu olmayan (opsiyonel) özel metin giriş alanı bulunur.
- Çıktı, PDFKit kullanılarak oluşturulmuş gerçek bir vector PDF olmalıdır.

### 4. Ayarlar (Settings)
- Varsayılan formül seçimi, Uygulama teması ve Dil Seçimi.

## Kod Yazım Kuralları
- **SIFIR YORUM SATIRI:** Kod dosyaları içine açıklama veya yorum satırı eklenmeyecektir.
- Magic number ve hardcoded string kullanmaktan kaçınılacak, her şey `String Catalogs` veya `Constants` üzerinden yönetilecektir.
- Yapılan her geliştirme sonrası, GitHub'a pushlanmak üzere yapılan işlemlerin detayını içeren bir Markdown metni (Issue veya Commit açıklaması için) hazırlanmalıdır.