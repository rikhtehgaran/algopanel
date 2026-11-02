# راهنمای سیستم نصب خودکار AlgoPanel

پوشه استقرار: `/home/mrg/Scripts/Projects/algopanel/installer/`

این ساختار برای ساخت و راه‌اندازی اسکریپت نصب اختصاصی شبیه `wget -O - https://get.algopanel.ir | sh` طراحی شده است.

---

### ۱. معماری سیستم نصب

فرآیند نصب دو مرحله‌ای است:
1. **اسکریپت اولیه (`install.sh`)**:
   - به آدرس مثل `https://algopanel.ir/install.sh` یا `https://get.algopanel.ir` قرار می‌گیرد.
   - میرورهای سرور را در صورت نیاز به میرورهای پرسرعت (مثل ابرآروان یا هر میرور دلخواه) تغییر می‌دهد.
   - پیش‌نیازهای اولیه (`php-cli`, `dialog`, `curl`, `wget`) را نصب می‌کند.
   - فایل بسته اتواینستالر (`algopanel-ai.tar.gz`) را از هاست دانلود و اجرا می‌کند.
2. **اتواینستالر PHP (`algopanel-ai`)**:
   - سرویس‌های سیستم (Apache/Nginx, MariaDB, Postfix, Dovecot و ...) را کانفیگ می‌کند.
   - بسته نهایی سورس پنل شما (`algopanel-stable.tar.gz`) را دانلود و نصب می‌کند.

---

### ۲. فایل‌هایی که باید روی هاست `algopanel.ir` قرار گیرند

در وب‌سرور دامنه `algopanel.ir`، فایل‌ها را در مسیری عمومی (مثلاً `/var/www/html/downloads/` یا ساب‌دامین `get.algopanel.ir`) قرار دهید:

| آدرس URL روی سرور | منبع فایل محلی | توضیحات |
| :--- | :--- | :--- |
| `https://algopanel.ir/install.sh` (یا `get.algopanel.ir`) | `installer/install.sh` | اسکریپت اصلی اجرای کاربر با `wget -O - ... \| sh` |
| `https://algopanel.ir/downloads/algopanel-ai.tar.gz` | `installer/dist/algopanel-ai.tar.gz` | آرشیو نصاب هوشمند و کلاس‌های کانفیگ سیستم |
| `https://algopanel.ir/downloads/algopanel-stable.tar.gz` | `installer/dist/algopanel-stable.tar.gz` | سورس کامل تغییریافته شما از پنل (پوشه `algopanel`) |
| `https://algopanel.ir/downloads/auto_update_phpmyadmin.sh` | `installer/auto_update_phpmyadmin.sh` | اسکریپت کرون آپدیت phpmyadmin |

---

### ۳. اسکریپت ساخت خودکار بسته‌ها (`build_packages.sh`)

هر زمان که در کد پنل یا در اسکریپت نصاب تغییراتی ایجاد کردید، با اجرای دستور زیر در ترمینال، بسته‌های `.tar.gz` فوراً مجدداً تولید می‌شوند:

```bash
/home/mrg/Scripts/Projects/algopanel/installer/build_packages.sh
```

این دستور فایل‌های `algopanel-stable.tar.gz` و `algopanel-ai.tar.gz` را در پوشه `dist` می‌سازد.

---

### ۴. نحوه تغییر و داینامیک‌سازی میرورها بر اساس IP / لوکیشن

در اسکریپت `install.sh` تابع `configure_mirrors` قرار داده شده است. شما می‌توانید با استفاده از متغیر محیطی یا چک کردن IP سرور (برای سرورهای داخل یا خارج ایران)، آدرس میرور را تغییر دهید:

نمونه منطق IP / لوکیشن:
```bash
COUNTRY=$(curl -s --connect-timeout 3 https://ipapi.co/country/ 2>/dev/null)
if [ "$COUNTRY" = "IR" ]; then
    # استفاده از مخازن ایران (ArvanCloud / Asiatech)
    MIRROR="http://mirror.arvancloud.ir/ubuntu"
else
    # استفاده از مخازن اصلی اوبونتو
    MIRROR="http://archive.ubuntu.com/ubuntu"
fi
```
این قابلیت در کد اسکریپت آماده توسعه بیشتر است.

---

### ۵. دستور نصب روی سرور کاربر نهایی

پس از قرار گرفتن فایل‌ها روی هاست `algopanel.ir`:

```bash
wget -O - https://algopanel.ir/install.sh | sh -s -- --help
# یا نصب کامل:
wget -O - https://algopanel.ir/install.sh | sh
```
