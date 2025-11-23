#!/bin/bash

# === Визначаємо теку, де знаходиться скрипт ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# === Очікувана версія пакету ===
EXPECTED_VERSION="11.1.0.11723.XA"

echo "=== Перевірка встановленої версії WPS Office ==="

# Перевіряємо, чи встановлено пакет wps-office
INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' wps-office 2>/dev/null)

if [ -z "$INSTALLED_VERSION" ]; then
    echo "Помилка: Пакет 'wps-office' не встановлено."
    echo "Будь ласка, встановіть wps-office версії $EXPECTED_VERSION."
    read -n1 -rsp $'Натисніть будь-яку клавішу для виходу…\n'
    exit 1
fi

# Порівнюємо версію (ігноруємо суфікси після .XA, якщо такі є)
# Точне співпадіння префікса "11.1.0.11723.XA"
if [[ "$INSTALLED_VERSION" != "$EXPECTED_VERSION"* ]]; then
    echo "Помилка: Встановлена версія WPS Office — $INSTALLED_VERSION"
    echo "Цей скрипт призначено лише для версії: $EXPECTED_VERSION"
    echo "Оновіть або встановіть правильну версію пакету."
    read -n1 -rsp $'Натисніть будь-яку клавішу для виходу…\n'
    exit 1
fi

echo "✓ Встановлена версія WPS Office: $INSTALLED_VERSION"

# === Далі йде скрипт ===

SOURCE_MUI="$SCRIPT_DIR/default"
SOURCE_DICTS="$SCRIPT_DIR/dicts_uk_UA"

# === Нові джерела ===
SOURCE_KSKINCENTER="$SCRIPT_DIR/addons_mui/kskincenter/app.js"
SOURCE_KOPTIONCENTER="$SCRIPT_DIR/addons_mui/koptioncenter/app.js"
SOURCE_KSTARTPAGE="$SCRIPT_DIR/addons_mui/kstartpage/default"
SOURCE_KNEWDOCS="$SCRIPT_DIR/addons_mui/knewdocs/app.js"

# === Джерела для піктограм та .desktop-файлів ===
SOURCE_ICONS="$SCRIPT_DIR/icons"
SOURCE_DESKTOPS="$SCRIPT_DIR/desktops"

TARGET_MUI_ROOT="/opt/kingsoft/wps-office/office6/mui"
TARGET_MUI="$TARGET_MUI_ROOT/default"
TARGET_DICTS="/opt/kingsoft/wps-office/office6/dicts"

# === Нові цілі ===
TARGET_KSKINCENTER="/opt/kingsoft/wps-office/office6/addons/kskincenter/static/js/"
TARGET_KOPTIONCENTER="/opt/kingsoft/wps-office/office6/addons/koptioncenter/mui/default/htmllinux/static/js/"
TARGET_KSTARTPAGE="/opt/kingsoft/wps-office/office6/addons/kstartpage/mui/"
TARGET_KNEWDOCS="/opt/kingsoft/wps-office/office6/addons/knewdocs/res/js/"

# === Системні цілі для піктограм та .desktop-файлів ===
TARGET_ICONS="/usr/share/icons/"
TARGET_DESKTOPS="/usr/share/applications/"

echo "=== Встановлення української локалізації WPS Office ==="

# === Перевірка наявності тек ===
if [ ! -d "$SOURCE_MUI" ]; then
    echo "Помилка: Теку 'default' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

if [ ! -d "$SOURCE_DICTS" ]; then
    echo "Помилка: Теку 'dicts_uk_UA' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

# === Перевірка нових файлів/тек ===
if [ ! -f "$SOURCE_KSKINCENTER" ]; then
    echo "Помилка: Файл 'addons_mui/kskincenter/app.js' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

if [ ! -f "$SOURCE_KOPTIONCENTER" ]; then
    echo "Помилка: Файл 'addons_mui/koptioncenter/app.js' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

if [ ! -d "$SOURCE_KSTARTPAGE" ]; then
    echo "Помилка: Теку 'addons_mui/kstartpage/default' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

if [ ! -f "$SOURCE_KNEWDOCS" ]; then
    echo "Помилка: Файл 'аddons_mui/knewdocs/app.js' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

# === Перевірка тек icons та desktops ===
if [ ! -d "$SOURCE_ICONS" ]; then
    echo "Помилка: Теку 'icons' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

if [ ! -d "$SOURCE_DESKTOPS" ]; then
    echo "Помилка: Теку 'desktops' не знайдено у: $SCRIPT_DIR"
    read -n1 -rsp $'Натисніть будь-яку клавішу…\n'
    exit 1
fi

echo "Підготовка до копіювання…"
sleep 1

# === Команда для виконання з root ===
COMMAND=$(cat <<EOF
echo "→ Очищення теки локалізації: $TARGET_MUI_ROOT"
rm -rf "$TARGET_MUI_ROOT"

echo "→ Створення нової структури mui/default"
mkdir -p "$TARGET_MUI"

echo "→ Копіювання файлів локалізації…"
cp -a "$SOURCE_MUI/"* "$TARGET_MUI/"

echo "→ Створення теки словників"
mkdir -p "$TARGET_DICTS"

echo "→ Копіювання словників…"
cp -a "$SOURCE_DICTS/"* "$TARGET_DICTS/"

# === Копіювання нових файлів та тек ===
echo "→ Копіювання kskincenter/app.js…"
cp -f "$SOURCE_KSKINCENTER" "$TARGET_KSKINCENTER"

echo "→ Копіювання knewdocs/app.js…"
cp -f "$SOURCE_KNEWDOCS" "$TARGET_KNEWDOCS"

echo "→ Копіювання koptioncenter/app.js…"
cp -f "$SOURCE_KOPTIONCENTER" "$TARGET_KOPTIONCENTER"

echo "→ Копіювання теки kstartpage/default…"
cp -a "$SOURCE_KSTARTPAGE/"* "$TARGET_KSTARTPAGE"

# === Копіювання піктограм та .desktop-файлів ===
echo "→ Копіювання піктограм у системну теку…"
cp -a "$SOURCE_ICONS/"* "$TARGET_ICONS"

echo "→ Копіювання .desktop-файлів у системну теку…"
cp -a "$SOURCE_DESKTOPS/"* "$TARGET_DESKTOPS"

echo "✓ Готово"
EOF
)

echo "Зараз з’явиться вікно запиту пароля адміністратора…"
sleep 1

pkexec /bin/bash -c "$COMMAND"
STATUS=$?

echo
if [ $STATUS -eq 0 ]; then
    echo "==============================================="
    echo "  Локалізацію, словники, піктограми та .desktop-файли успішно встановлено!"
    echo "==============================================="
else
    echo "***********************************************"
    echo "  Сталася помилка під час встановлення файлів!"
    echo "***********************************************"
fi

read -n1 -rsp $'Натисніть будь-яку клавішу для виходу…\n'
