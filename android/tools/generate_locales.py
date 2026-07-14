import json
import pathlib
import re
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
IOS_CATALOG = ROOT.parent / "Kubaj" / "Resources" / "Localizable.xcstrings"
DEFAULT_XML = ROOT / "app" / "src" / "main" / "res" / "values" / "strings.xml"

KEY_MAP = {
    "app_name": "app.name",
    "splash_tagline": "splash.tagline",
    "tab_home": "tab.home",
    "tab_grouping": "tab.grouping",
    "tab_folders": "tab.folders",
    "tab_settings": "tab.settings",
    "diameter_cm": "home.diameter_cm",
    "top_diameter_cm": "home.top_diameter_cm",
    "mid_diameter_cm": "home.mid_diameter_cm",
    "butt_diameter_cm": "home.butt_diameter_cm",
    "width_cm": "lumber.width_cm",
    "thickness_cm": "lumber.thickness_cm",
    "length_m": "home.length_m",
    "quantity": "home.quantity",
    "calculate": "home.calculate",
    "calculate_hollow": "home.calculate_hollow",
    "add_to_list": "hollow.add_to_list",
    "save": "home.save",
    "total_volume": "home.total_volume",
    "product_count": "home.logs_count",
    "average_diameter": "home.avg_diameter",
    "calculations": "home.recent_additions",
    "empty_calculations": "home.empty_state",
    "active_session": "grouping.draft_session",
    "select_file": "grouping.select_folder",
    "grouping_empty": "grouping.empty_state",
    "folders_empty": "folders.empty_state",
    "create_file": "folder_selection.create_folder",
    "file_name": "folder_selection.name_placeholder",
    "confirm": "folder_selection.confirm_save",
    "cancel": "common.cancel",
    "delete": "home.confirm_delete_action",
    "delete_confirmation": "home.confirm_delete_message",
    "export_pdf": "export.confirm_pdf",
    "export_excel": "export.confirm_xlsx",
    "export_file_name": "home.save_file_placeholder",
    "export_settings": "export.settings_title",
    "company_name": "export.report.company_name_label",
    "report_date": "export.report.report_date_label",
    "location": "export.report.location_label",
    "reporter": "export.report.reporter_label",
    "project_code": "export.report.project_code_label",
    "settings_calculation_methods": "settings.engine_preferences_section",
    "settings_theme": "settings.theme",
    "settings_language": "settings.language_picker_title",
    "settings_haptics": "settings.haptic_feedback",
    "theme_system": "settings.theme_system",
    "theme_light": "settings.theme_light",
    "theme_dark": "settings.theme_dark",
    "formula_huber": "calculation_method.huber",
    "formula_smalian": "calculation_method.smalian",
    "formula_newton": "calculation_method.newton",
    "formula_ulker": "calculation_method.ulker",
    "outer_diameter": "hollow.outer_diameter",
    "inner_diameter": "hollow.inner_diameter",
    "equivalent_diameter": "hollow.equivalent_diameter_format",
    "net_volume": "hollow.net_volume_format",
    "add_diameter": "hollow.add_diameter_format",
    "table_no": "home.table_no",
    "table_length": "home.table_length",
    "table_quantity": "home.table_qty",
    "table_diameter": "home.table_diameter",
    "table_volume": "home.table_vol",
    "total": "export.total_row_label",
    "onboarding_title_1": "onboarding.step1_title_line1",
    "onboarding_body_1": "onboarding.step1_subtitle",
    "onboarding_title_2": "onboarding.step2_title_line1",
    "onboarding_body_2": "onboarding.step2_subtitle",
    "onboarding_title_3": "onboarding.step3_title_line1",
    "onboarding_body_3": "onboarding.step3_subtitle",
    "next": "onboarding.next_step",
    "get_started": "onboarding.get_started",
}

CUSTOM = {
    "de": {
        "export_excel": "Excel erstellen",
        "export_file_name": "Name der Exportdatei",
        "folders_empty": "Keine Dateien mit Einträgen",
        "delete_confirmation": "Diese Aktion kann nicht rückgängig gemacht werden. Löschen?",
    },
    "es": {
        "export_excel": "Generar Excel",
        "export_file_name": "Nombre del archivo exportado",
        "folders_empty": "No hay archivos con registros",
        "delete_confirmation": "Esta acción no se puede deshacer. ¿Desea eliminar?",
    },
    "pt": {
        "export_excel": "Gerar Excel",
        "export_file_name": "Nome do arquivo exportado",
        "folders_empty": "Nenhum arquivo com registros",
        "delete_confirmation": "Esta ação não pode ser desfeita. Deseja excluir?",
    },
    "fr": {
        "export_excel": "Générer Excel",
        "export_file_name": "Nom du fichier exporté",
        "folders_empty": "Aucun fichier avec des enregistrements",
        "delete_confirmation": "Cette action est irréversible. Voulez-vous supprimer ?",
    },
    "sv": {
        "export_excel": "Skapa Excel",
        "export_file_name": "Namn på exportfil",
        "folders_empty": "Inga filer med poster",
        "delete_confirmation": "Åtgärden kan inte ångras. Vill du radera?",
    },
    "fi": {
        "export_excel": "Luo Excel",
        "export_file_name": "Vientitiedoston nimi",
        "folders_empty": "Ei tiedostoja, joissa on tietueita",
        "delete_confirmation": "Toimintoa ei voi peruuttaa. Haluatko poistaa?",
    },
    "ru": {
        "export_excel": "Создать Excel",
        "export_file_name": "Имя экспортируемого файла",
        "folders_empty": "Нет файлов с записями",
        "delete_confirmation": "Это действие нельзя отменить. Удалить?",
    },
}


def android_format(value):
    return (
        value.replace("%lld", "%1$d")
        .replace("%@", "%1$s")
        .replace("%.3f", "%1$.3f")
        .replace("'", "\\'")
    )


catalog = json.loads(IOS_CATALOG.read_text())["strings"]
default_values = {
    node.attrib["name"]: node.text or ""
    for node in ET.parse(DEFAULT_XML).getroot().findall("string")
}

for language in ("de", "es", "pt", "fr", "sv", "fi", "ru"):
    resources = ET.Element("resources")
    for android_key, default_value in default_values.items():
        ios_key = KEY_MAP.get(android_key)
        unit = (
            catalog.get(ios_key, {})
            .get("localizations", {})
            .get(language, {})
            .get("stringUnit", {})
        )
        value = CUSTOM.get(language, {}).get(android_key) or unit.get("value") or default_value
        if android_key == "net_volume":
            value = re.sub(r"%(@|lld|[\d$.]*f)", "%1$.3f", value)
        elif android_key in {"equivalent_diameter", "add_diameter"}:
            value = re.sub(r"%(@|lld|[\d$]*d)", "%1$d", value)
        node = ET.SubElement(resources, "string", {"name": android_key})
        node.text = android_format(value)
    ET.indent(resources, space="    ")
    output = ROOT / "app" / "src" / "main" / "res" / f"values-{language}" / "strings.xml"
    output.write_text('<?xml version="1.0" encoding="utf-8"?>\n' + ET.tostring(resources, encoding="unicode"))
