<p align="center">
  <a href="https://algopanel.ir">
    <img src="interface/web/themes/algopanel/assets/images/logo.png" alt="AlgoPanel Logo" width="280">
  </a>
</p>

<h1 align="center">AlgoPanel</h1>

<p align="center">
  <strong>Free, modern, high-performance web hosting control panel for Linux servers</strong><br>
  Engineered by <a href="http://www.algo4stock.com">Algo4Stock Software Corp</a>
</p>

<p align="center">
  <a href="https://github.com/rikhtehgaran/algopanel/releases"><img src="https://img.shields.io/badge/version-1.0.9-blue.svg" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-green.svg" alt="License"></a>
  <a href="https://algopanel.ir"><img src="https://img.shields.io/badge/website-algopanel.ir-blueviolet.svg" alt="Website"></a>
</p>

---

## 🌐 English Documentation

### 📖 About AlgoPanel

**AlgoPanel** is a powerful, secure, and modern open-source web hosting control panel designed for Linux servers. Built upon the battle-tested architecture of **ISPConfig**, AlgoPanel has been overhauled with modern UI enhancements, enterprise automation, high-speed intelligent mirror resolution, and extensive multi-server clustering capabilities.

AlgoPanel allows system administrators, hosting providers, and developers to manage single servers or distributed multi-server clusters effortlessly through a sleek web interface.

---

### ✨ Key Features

- **Websites & Virtual Hosts:**
  - Full support for Apache2 and NGINX web servers.
  - Multi-PHP support: run multiple PHP versions simultaneously (PHP 7.4 through 8.4) via PHP-FPM / FastCGI per website.
  - Automated SSL issuance & renewal powered by Let's Encrypt (Acme.sh & Certbot).
  - Subdomains, alias domains, directory protection, custom vhost directives, and custom error pages.

- **Enterprise Mail Server:**
  - Robust mail stack powered by Postfix & Dovecot (POP3 / IMAP / LMTP).
  - Intelligent spam & malware filtering with Rspamd and Amavis.
  - Out-of-the-box support for SPF, DKIM, and DMARC verification.
  - Roundcube Webmail integration, email aliases, forwarders, and autoresponders.

- **Database Management:**
  - Complete management for MariaDB and MySQL databases.
  - Granular user permissions, remote access controls, and phpMyAdmin integration.

- **DNS Server (Domain Name Service):**
  - Robust BIND9 and PowerDNS integration.
  - Full management of DNS zones and record types (A, AAAA, CNAME, MX, TXT, SRV, CAA, DNSSEC).
  - Native DNS Master/Slave replication support.

- **Scalability & Clustering:**
  - Multi-server architecture: distribute Web, Mail, Database, and DNS across dedicated nodes controlled by a central master node.
  - Mirrored server setups for High Availability (HA).

- **Multi-tier User Hierarchy:**
  - 4 distinct role levels: Administrator, Reseller, Client, and Mail User.

- **Security & Protection:**
  - Deep integration with Fail2ban for brute-force attack prevention.
  - Built-in firewall management (UFW / iptables) and IP whitelisting.

---

### 💻 Supported Operating Systems

- **Debian:** 11 (Bullseye), 12 (Bookworm), 13 (Trixie)
- **Ubuntu:** 20.04 LTS, 22.04 LTS, 24.04 LTS
- **RHEL Family:** AlmaLinux, Rocky Linux, CentOS (8 / 9 / 10)

---

### 🚀 Quick Installation

AlgoPanel features an intelligent autoinstaller that automatically detects server geolocation and selects the fastest, most reliable package mirrors:

```bash
wget -O - https://get.algopanel.ir | sh
```

Or run directly:
```bash
wget -O - https://algopanel.ir/install.sh | sh
```

> **Installation Options & Help:**
> ```bash
> wget -O - https://algopanel.ir/install.sh | sh -s -- --help
> ```

---

### 🛠️ Development with Docker

To spin up a local development and testing environment:

```bash
git clone https://github.com/rikhtehgaran/algopanel.git
cd algopanel
docker compose up -d
```

---

### 📜 License & Copyright

- **License:** Licensed under the [Apache License, Version 2.0](LICENSE).
- **Development & Maintenance:**
  - Lead Developer: **Danial Rikhteh Garan**
  - Copyright: © 2025–2026 **[Algo4Stock Software Corp](http://www.algo4stock.com)**
  - Official Website: [https://algopanel.ir](https://algopanel.ir)

---

<!-- ========================================================================= -->
<!-- Persian (Farsi) Section with RTL wrapper and Vazirmatn font support       -->
<!-- ========================================================================= -->

<div dir="rtl" style="font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">

<p align="center">
  <img src="https://fonts.googleapis.com/css2?family=Vazirmatn:wght@400;600;800&display=swap" alt="" width="0" height="0" />
</p>

# بخش مستندات فارسی (الگوپنل)

### 📖 درباره الگوپنل

**الگوپنل (AlgoPanel)** یک کنترل‌پنل متن‌باز، امن و سبک برای مدیریت میزبانی وب و سرورهای لینوکس است. این پروژه بر پایه معماری آزموده‌شده **ISPConfig** توسعه یافته و برای عملکرد بالا، استقرار آسان، بهینه‌سازی منابع سرور و هماهنگی کامل با زیرساخت‌های بین‌المللی و داخلی بازمهندسی شده است.

الگوپنل امکان مدیریت یکپارچه از یک سرور اختصاصی تا خوشه‌ها و کلاسترهای بزرگ چندسروری (Multi-Server) را در قالبی مدرن و روان فراهم می‌کند.

---

### ✨ قابلیت‌ها و ویژگی‌های کلیدی

- **مدیریت وب‌سایت‌ها و هاست‌های مجازی (Websites & VHosts):**
  - پشتیبانی کامل از وب‌سرورهای قدرتمند Apache2 و NGINX.
  - پشتیبانی هم‌زمان از چندین نسخه PHP (از PHP 7.4 تا 8.4) به‌ازای هر دامنه با PHP-FPM / FastCGI.
  - خودکارسازی دریافت و تمدید گواهینامه‌های SSL رایگان با Let's Encrypt (از طریق Acme.sh و Certbot).
  - مدیریت ساب‌دامین‌ها، دامنه‌های مستعار (Alias)، صفحات خطای اختصاصی و دایرکتوری‌های رمزگذاری‌شده.

- **سرور ایمیل سازمانی (Mail Server):**
  - استک ایمیل پایدار و استاندارد بر پایه Postfix و Dovecot (پشتیبانی از POP3/IMAP/LMTP).
  - فیلترینگ پیشرفته هرزنامه‌ها و بدافزارها با Rspamd و Amavis.
  - پیاده‌سازی و تنظیم خودکار رکوردهای امنیتی SPF، DKIM و DMARC.
  - وب‌میل کاربرپسند Roundcube، مدیریت فورواردرها، الیاس‌ها و پاسخ‌گوی خودکار.

- **مدیریت پایگاه‌های داده (Databases):**
  - پشتیبانی کامل از MariaDB و MySQL.
  - ایجاد آسان دیتابیس و کاربران مجزا با دسترسی ریموت و پیوند مستقیم با phpMyAdmin.

- **مدیریت سرویس نام دامنه (DNS Server):**
  - سازگاری کامل با BIND9 و PowerDNS.
  - مدیریت کامل انواع Zoneها و رکوردهای DNS (A, AAAA, CNAME, MX, TXT, SRV, CAA, DNSSEC).
  - پشتیبانی بومی از ساختار Master/Slave برای DNS.

- **معماری توزیع‌شده و کلاسترینگ (Multi-Server):**
  - امکان جداسازی سرویس‌ها (وب، ایمیل، دیتابیس و DNS) روی سرورهای اختصاصی مجزا از طریق یک نود مدیریتی مرکزی.
  - پشتیبانی از افزونگی و Mirroring برای دسترسی‌پذیری بالا (High Availability).

- **سطوح دسترسی سازمانی:**
  - ۴ سطح دسترسی مستقل: مدیر ارشد (Administrator)، نماینده (Reseller)، مشتری (Client) و کاربر ایمیل (Mail User).

- **امنیت و دیواره آتش (Firewall):**
  - یکپارچه‌سازی با Fail2ban جهت مقابله هوشمند با حملات Brute-Force.
  - مدیریت فایروال سیستم (UFW / iptables) و تعریف لیست سفید/سیاه IPها.

---

### 💻 سیستم‌عامل‌های تحت پشتیبانی

- **Debian:** نسخه‌های 11 (Bullseye)، 12 (Bookworm) و 13 (Trixie)
- **Ubuntu:** نسخه‌های 20.04 LTS، 22.04 LTS و 24.04 LTS
- **خانواده RHEL:** شامل AlmaLinux، Rocky Linux و CentOS (نسخه‌های 8 / 9 / 10)

---

### 🚀 نصب سریع و آسان

نصاب خودکار الگوپنل بر اساس موقعیت جغرافیایی IP سرور شما (ایران یا خارج از کشور)، نزدیک‌ترین و پرسرعت‌ترین مخازن دانلود را به‌صورت هوشمند انتخاب می‌کند:

```bash
wget -O - https://get.algopanel.ir | sh
```

یا اجرای مستقیم از دامنه اصلی:
```bash
wget -O - https://algopanel.ir/install.sh | sh
```

> **راهنمای سوئیچ‌ها و گزینه‌های نصب:**
> ```bash
> wget -O - https://algopanel.ir/install.sh | sh -s -- --help
> ```

---

### 🛠️ توسعه و اجرای محلی با داکر (Docker)

برای راه‌اندازی سریع محیط توسعه و تست محلی:

```bash
git clone https://github.com/rikhtehgaran/algopanel.git
cd algopanel
docker compose up -d
```

---

### 📜 لایسنس و مالکیت حقوقی

- **مجوز نرم‌افزار:** تحت لایسنس رسمی [Apache License 2.0](LICENSE) منتشر شده است.
- **توسعه و نگهداری:**
  - توسعه‌دهنده اصلی: **Danial Rikhteh Garan**
  - حق نشر: © 2025–2026 شرکت **[Algo4Stock Software Corp](http://www.algo4stock.com)**
  - وب‌سایت رسمی: [https://algopanel.ir](https://algopanel.ir)

</div>
