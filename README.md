<p align="center">
  <a href="https://algopanel.ir">
    <img src="interface/web/themes/algopanel/assets/images/logo.png" alt="AlgoPanel Logo" width="280">
  </a>
</p>

<h1 align="center">AlgoPanel (الگوپنل)</h1>

<p align="center">
  <strong>کنترل‌پنل هاستینگ آزاد، قدرتمند و بهینه‌سازی‌شده برای سرورهای لینوکس</strong><br>
  توسعه‌یافته توسط <a href="http://www.algo4stock.com">Algo4Stock Software Corp</a>
</p>

<p align="center">
  <a href="https://github.com/rikhtehgaran/algopanel/releases"><img src="https://img.shields.io/badge/version-1.0.7-blue.svg" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-green.svg" alt="License"></a>
  <a href="https://algopanel.ir"><img src="https://img.shields.io/badge/website-algopanel.ir-blueviolet.svg" alt="Website"></a>
</p>

---

## 📖 درباره الگوپنل (About AlgoPanel)

**الگوپنل (AlgoPanel)** یک کنترل‌پنل کامل، امن و متن‌باز برای مدیریت میزبانی وب و سرورهای لینوکس است که بر پایه پلتفرم اثبات‌شده **ISPConfig** توسعه یافته و برای عملکرد بالا، استقرار آسان، تم مدرن و سازگاری با زیرساخت‌های بین‌المللی و محلی بازمهندسی شده است.

الگوپنل این امکان را به شما می‌دهد که از یک سرور واحد تا خوشه‌ها و کلاسترهای چندسروری (Multi-Server Clusters) توزیع‌شده را به‌سادگی از طریق یک رابط کاربری وب مدرن مدیریت نمایید.

---

## ✨ ویژگی‌ها و قابلیت‌های کلیدی (Key Features)

- **مدیریت وب‌سایت‌ها (Websites & VHosts):**
  - پشتیبانی از وب‌سرورهای Apache2 و NGINX
  - قابلیت اجرای هم‌زمان چندین نسخه PHP (PHP 7.4 تا 8.4) به‌ازای هر وب‌سایت از طریق PHP-FPM / FastCGI
  - صدور و تمدید خودکار گواهینامه‌های رایگان SSL با Let's Encrypt (Acme.sh و Certbot)
  - مدیریت زیردامنه‌ها (Subdomains)، دامنه‌های مستعار (Alias domains) و دایرکتوری‌های محافظت‌شده

- **مدیریت ایمیل سازمانی (Mail Server):**
  - سرور ارسال و دریافت مبتنی بر Postfix و Dovecot (POP3/IMAP/LMTP)
  - فیلترینگ هوشمند اسپم با Rspamd / Amavis
  - پشتیبانی کامل از رکوردهای احراز هویت امنیتی SPF، DKIM و DMARC
  - ادغام وب‌میل Roundcube و مدیریت صندوق‌های پستی، Aliasها و پاسخ‌گوی خودکار (Autoresponder)

- **مدیریت پایگاه داده (Databases):**
  - پشتیبانی کامل از MariaDB و MySQL
  - ایجاد دیتابیس و دسترسی‌های کاربری مجزا با مدیریت ریموت و مدیریت مستقیم از طریق phpMyAdmin

- **مدیریت سرور نام دامنه (DNS Server):**
  - پشتیبانی از BIND9 و PowerDNS
  - مدیریت کامل انواع Zoneها و رکوردهای DNS (A, AAAA, CNAME, MX, TXT, SRV, CAA, DNSSEC)
  - قابلیت کارکرد به‌صورت DNS Master/Slave

- **خوشه‌بندی و مقیاس‌پذیری (Multi-Server Architecture):**
  - مدیریت چندین سرور مستقل (وب‌سرور، میل‌سرور، دیتابیس‌سرور، DNS) از طریق یک پنل مرکزی (Control Node)
  - افزونگی و کلاسترینگ Mirrored برای دسترس‌پذیری بالا (High Availability)

- **سطوح دسترسی سلسله‌مراتبی (Role-based Access):**
  - ۴ سطح دسترسی مستقل: مدیر کل (Administrator)، نمایندگی (Reseller)، مشتری (Client)، و کاربر ایمیل (Mail User)

- **امنیت و فایروال پیشرفته:**
  - هماهنگی با Fail2ban برای مسدودسازی خودکار حملات Brute-Force
  - پشتیبانی از فایروال‌های سیستم (UFW / iptables) و کنترل دسترسی بر پایه IP

---

## 💻 سیستم‌عامل‌های تحت پشتیبانی (Supported OS)

الگوپنل روی توزیع‌های مدرن لینوکس سازگار است:
- **Debian:** 11 (Bullseye), 12 (Bookworm), 13 (Trixie)
- **Ubuntu:** 20.04 LTS, 22.04 LTS, 24.04 LTS
- **RHEL Family:** AlmaLinux, Rocky Linux, CentOS (8 / 9 / 10)

---

## 🚀 نصب خودکار و سریع (Quick Installation)

الگوپنل مجهز به سیستم نصب خودکار هوشمند با قابلیت **تشخیص خودکار موقعیت جغرافیایی سرور و استفاده از پرسرعت‌ترین مخازن و میرورها** است:

```bash
wget -O - https://get.algopanel.ir | sh
```
یا با مشخص کردن مستقیم اسکریپت:
```bash
wget -O - https://algopanel.ir/install.sh | sh
```

> **نکته:** جهت مشاهده تمام آرگومان‌ها و راهنمای نصب بدون انجام تغییرات:
> ```bash
> wget -O - https://algopanel.ir/install.sh | sh -s -- --help
> ```

---

## 🛠️ توسعه و ساخت با Docker

برای توسعه و اجرای محیط آزمایشی با داکر:

```bash
git clone https://github.com/rikhtehgaran/algopanel.git
cd algopanel
docker compose up -d
```

---

## 📜 لایسنس و حق نشر (License & Copyright)

- **کد پایه (Core Application):** تحت مجوز متن‌باز [BSD 3-Clause License](LICENSE).
- **حقوق تجاری و توسعه:**
  - توسعه‌دهنده: **Danial Rikhteh Garan**
  - حق نشر: © 2025–2026 شرکت **[Algo4Stock Software Corp](http://www.algo4stock.com)**
  - وب‌سایت رسمی: [https://algopanel.ir](https://algopanel.ir)
