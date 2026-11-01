# Extension Limits

A reference for adding client / reseller / client-template **limits** from an
extension, without modifying any of the limit forms, templates, language files
or the dashboard dashlet in the core.

Audience: anyone (human or AI) implementing an extension that needs to register
one or more limit fields.

---

## 1. What this mechanism does

ISPConfig stores per-client limits (e.g. `limit_web_domain`, `limit_mailbox`)
as columns on the `client` and `client_template` tables, and renders them on the
client, reseller and client-template edit forms. Historically a new limit had to
be hardcoded into a dozen core files.

The **limit registry** removes that requirement. An extension drops a single
definition file into a directory, and the core then:

1. **injects** the limit fields into the `client` / `reseller` /
   `client_template` form definitions, so the form layer validates them,
   persists them, and exposes them through the SOAP/remote API;
2. **renders** the fields in a generic accordion panel on the three edit forms;
3. **provides** the label texts used outside the render loop;
4. **adds** usage/quota bars to the client dashboard "limits" dashlet.

The extension keeps ownership of two things only:

- its **database schema** — the `ALTER TABLE` that adds the limit columns;
- its **enforcement** — the `checkClientLimit()` / `checkResellerLimit()` calls
  in the extension's own edit controllers.

No limit-specific naming lives in the core. The mechanism is fully generic and
works for any number of extensions at once.

---

## 2. Quick start

1. Add your limit columns to the `client` and `client_template` tables (§6).
2. Drop a definition file at
   `interface/web/client/lib/limits.d/<your_extension>.php` (§4).
3. Call `checkClientLimit()` / `checkResellerLimit()` in your extension's edit
   controllers (§7).

That is the whole integration. The panel, validation, persistence, template
merge, SOAP exposure and dashboard bars follow automatically.

---

## 3. The drop-in directory

```
interface/web/client/lib/limits.d/<your_extension>.php
```

The registry scans `interface/web/client/lib/limits.d/*.php` once per request. The
core ships this directory with an `empty.dir` placeholder; your installer simply
copies one file into it.

A single central directory is used (not one per module) because limits are only
ever edited in the client module. One file per extension keeps installs and
uninstalls trivial: drop the file to enable, delete it to disable.

---

## 4. Definition file format

A definition file **returns an array**. Minimal example:

```php
<?php
return array(
    'extension' => 'example',                 // unique key, used for dedup
    'section'   => array(
        'id'    => 'Example',                 // -> accordion panel "collapseExample"
        'title' => 'Example limits',          // panel heading
        'order' => 80,                        // sort position among panels
    ),
    'limits' => array(
        'limit_example' => array(
            'label'      => 'Max. number of examples',
            'datatype'   => 'INTEGER',
            'formtype'   => 'TEXT',
            'default'    => '-1',
            'validators' => array(
                array('type'   => 'ISINT',
                      'errmsg' => 'Max. number of examples must be a number.'),
            ),
            'applies_to' => array('client', 'reseller', 'client_template'),
            'usage'      => array(
                'db_table' => 'example_item',
                'db_where' => '',
            ),
        ),
    ),
);
```

### 4.1 Top-level keys

| Key | Required | Meaning |
|---|---|---|
| `extension` | yes | Unique string key for this definition. Used to de-duplicate and as a logging handle. |
| `min_core` | no | Minimum core version (e.g. `'3.3.2'`). If the installed core is older, the whole definition is skipped. Development builds are always treated as current. |
| `section` | no | The accordion panel the fields are grouped into. Defaults to a generic "Extensions" panel. |
| `limits` | yes | Map of `column_name => field definition`. |

### 4.2 The `section` block

| Key | Meaning |
|---|---|
| `id` | Identifier used to build the panel's HTML ids (`heading<id>`, `collapse<id>`). Keep it alphanumeric. |
| `title` | The heading shown on the panel. |
| `order` | Integer sort position. Panels from all extensions are ordered by this value. |

Two extensions may share the same `section.id` to render their fields in **one
shared panel**; a different `id` produces a **separate panel**.

### 4.3 A limit's field definition

| Key | Required | Meaning |
|---|---|---|
| `label` | yes | The field label (also used as `<column>_txt` for the dashlet and other placeholders). |
| `datatype` | no | tform datatype. Defaults to `INTEGER`. |
| `formtype` | no | tform formtype. Defaults to `TEXT`. |
| `default` | no | Default value for new records. Defaults to `-1` (the "unlimited" convention). |
| `validators` | no | Array of tform validators. See §4.4. |
| `applies_to` | no | Which forms the limit appears on: any of `client`, `reseller`, `client_template`. Defaults to all three. |
| `usage` | no | Dashboard usage reporting. See §4.5. |

Additional tform field keys are passed through verbatim, so any field type is
supported (not only `INTEGER`/`TEXT`): `value`, `separator`, `width`,
`maxlength`, `regex`, `filters`.

### 4.4 Validators and error messages

Validators use the standard tform validator format. The important convention is
the **`errmsg`**: put the **full human-readable message text** there, not a
language-file key.

```php
'validators' => array(
    array('type' => 'ISINT', 'errmsg' => 'Max. number of examples must be a number.'),
),
```

The form layer renders the `errmsg` verbatim when it is not found as a wordbook
key, so the message displays correctly without the extension shipping language
files. (The label text in `label` is likewise inline.)

### 4.5 The `usage` block (dashboard reporting)

If a limit declares a `usage` block, the client dashboard "limits" dashlet shows
a usage/quota bar for it. The dashlet counts rows generically, exactly like the
built-in limits.

| Key | Meaning |
|---|---|
| `db_table` | The table whose rows represent the consumed items. |
| `db_where` | Optional extra SQL `WHERE` fragment (without the leading `AND`). |
| `q_type` | Optional. Set to a column name for a **sum/quota** style limit (the dashlet sums that column instead of counting rows). |

Omit the whole `usage` block to keep a limit out of the dashlet.

---

## 5. The naming rule (hard requirement)

**Every limit column name must contain the substring `limit`.**

Examples: `limit_example`, `limit_example_size`, `example_limit`.

The client-template engine recognises a column as a limit purely by this
substring when it merges templates onto clients. A limit column without `limit`
in its name will be stored, but it will **not** be carried by client templates.

---

## 6. Database schema (owned by the extension)

The extension's installer adds the limit columns. Resellers are stored in the
`client` table, so reseller limits need columns on `client` (no separate reseller
table). Limits that apply to client templates also need the column on
`client_template`.

```sql
ALTER TABLE `client`          ADD COLUMN IF NOT EXISTS `limit_example` int(11) NOT NULL DEFAULT '-1';
ALTER TABLE `client_template` ADD COLUMN IF NOT EXISTS `limit_example` int(11) NOT NULL DEFAULT '-1';
```

Rules of thumb:

- A limit with `applies_to` containing `client` or `reseller` → column on
  `client`.
- A limit with `applies_to` containing `client_template` → column on
  `client_template`.
- The `-1` default is the "unlimited" convention used throughout ISPConfig.

### Install ordering and the missing-column guard

Install the columns **and** the definition file together. As a safety net, the
registry verifies that a limit's backing column actually exists before using it:
a limit whose column is missing is silently skipped (no panel, no SOAP field, no
broken SQL). This keeps a half-finished install from breaking the client edit
form. It is a safety net, not a substitute for installing both parts.

To **uninstall**, remove the definition file. You may keep or drop the columns;
while the file is gone the columns are simply ignored by the forms.

---

## 7. Enforcement (owned by the extension)

The registry makes the limits visible, editable and stored. **Enforcing** them
at create time is the extension's job, done in the extension's own edit
controllers with the generic core helpers:

```php
// In your extension's *_edit.php controller, before allowing a new item:
if(!$app->tform->checkClientLimit('limit_example')) {
    $app->error($app->tform->wordbook['limit_example_txt'] . ': ' . $app->tform->lng('limit_reached_txt'));
}
if(!$app->tform->checkResellerLimit('limit_example')) {
    $app->error($app->tform->wordbook['limit_example_txt'] . ': ' . $app->tform->lng('limit_reached_txt'));
}
```

`checkClientLimit($name)` compares the count of existing rows in the form's table
against the logged-in client's value of column `$name`. `checkResellerLimit()`
does the same against the client's reseller. Both are generic and need no
registry awareness.

---

## 8. How it fits together (for reference)

You do not need to touch any of the following — it is listed so the data flow is
clear.

| Concern | Where it happens |
|---|---|
| Field injection into forms | `limits_registry::apply_to_form()` is called at the end of `client.tform.php`, `reseller.tform.php`, `client_template.tform.php`. This drives tform validation, persistence, and SOAP exposure. |
| Rendering | A generic `<tmpl_loop>` accordion block in the three `*_edit_limits.htm` templates, populated by the controllers via `limits_registry::get_template_sections()`. |
| Labels outside the loop | `limits_registry::get_labels()` (merged into the form wordbook and the dashlet). |
| Dashboard bars | `limits_registry::get_dashlet_limits()` merged into the dashlet's limit list. |
| Client-template merge | The core template engine treats any `limit*` column generically; no per-field code. |
| SOAP / remote API | The remote API loads the same form definitions, so injected fields round-trip automatically. |

The registry class is `interface/lib/classes/limits_registry.inc.php`, loaded
with `$app->load('limits_registry')`.

---

## 9. Worked example

An extension `example` that ships scheduled jobs with two limits — a count and a
total size — grouped in one panel, both shown on the dashboard.

`interface/web/client/lib/limits.d/example.php`:

```php
<?php
return array(
    'extension' => 'example',
    'min_core'  => '3.3.2',
    'section'   => array('id' => 'Example', 'title' => 'Example jobs', 'order' => 80),
    'limits'    => array(
        'limit_example_job' => array(
            'label'      => 'Max. number of jobs',
            'datatype'   => 'INTEGER',
            'formtype'   => 'TEXT',
            'default'    => '-1',
            'validators' => array(
                array('type' => 'ISINT', 'errmsg' => 'Max. number of jobs must be a number.'),
            ),
            'applies_to' => array('client', 'reseller', 'client_template'),
            'usage'      => array('db_table' => 'example_job', 'db_where' => ''),
        ),
        'limit_example_size' => array(
            'label'      => 'Max. total job size (MB)',
            'datatype'   => 'INTEGER',
            'formtype'   => 'TEXT',
            'default'    => '-1',
            'validators' => array(
                array('type' => 'ISINT', 'errmsg' => 'Max. total job size must be a number.'),
            ),
            'applies_to' => array('client', 'reseller', 'client_template'),
            'usage'      => array('db_table' => 'example_job', 'db_where' => '', 'q_type' => 'size_mb'),
        ),
    ),
);
```

Installer SQL:

```sql
-- The extension's own data table (referenced by the 'usage' block for dashboard reporting)
CREATE TABLE IF NOT EXISTS `example_job` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT 'riud',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT 'ru',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `size_mb` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Limit columns on the client / client_template tables
ALTER TABLE `client`          ADD COLUMN IF NOT EXISTS `limit_example_job`  int(11) NOT NULL DEFAULT '-1';
ALTER TABLE `client`          ADD COLUMN IF NOT EXISTS `limit_example_size` int(11) NOT NULL DEFAULT '-1';
ALTER TABLE `client_template` ADD COLUMN IF NOT EXISTS `limit_example_job`  int(11) NOT NULL DEFAULT '-1';
ALTER TABLE `client_template` ADD COLUMN IF NOT EXISTS `limit_example_size` int(11) NOT NULL DEFAULT '-1';
```

Enforcement in `example_job_edit.php`:

```php
if(!$app->tform->checkClientLimit('limit_example_job'))   { /* refuse */ }
if(!$app->tform->checkResellerLimit('limit_example_job')) { /* refuse */ }
```

---

## 10. Extension author checklist

- [ ] Every limit column name contains the substring `limit` (§5).
- [ ] Columns added to `client` (for `client`/`reseller`) and/or
      `client_template` (for `client_template`) with a sensible default, usually
      `-1` (§6).
- [ ] Definition file at `interface/web/client/lib/limits.d/<extension>.php` returns
      an array with `extension` and `limits` (§4).
- [ ] Each limit has a `label`; numeric limits have an `ISINT` validator whose
      `errmsg` is the full message text (§4.4).
- [ ] `applies_to` lists exactly the forms you intend (§4.3).
- [ ] Optional `usage` block added for any limit that should appear on the
      dashboard (§4.5).
- [ ] Definition file and columns are installed together, and both are removed on
      uninstall (§6).
- [ ] `checkClientLimit()` / `checkResellerLimit()` called in the extension's own
      edit controllers (§7).

---

## 11. Manual test plan

1. **Not installed** — client / reseller / client-template edit pages render
   exactly as before; no extra panel; no notices; dashlet unchanged.
2. **Installed** — the panel appears on all forms listed in `applies_to`, with
   one input per limit defaulting to the configured default.
3. **Persistence** — set values, save, reload → values persist.
4. **Validation** — enter a non-integer into an `ISINT` limit → the message from
   `errmsg` is shown and the save is rejected.
5. **Client template** — create a template with the limits, assign it as master
   to a client → the limits are written onto the client; additional templates add
   up as expected.
6. **Enforcement** — a client/reseller hits the limit → creating the next item is
   refused by `checkClientLimit()` / `checkResellerLimit()`.
7. **Dashboard** — limits with a `usage` block show usage/percentage bars.
8. **Remote API** — `client_add` / `client_update` accept and round-trip the
   limit fields.
9. **Multiple extensions** — a second definition sharing a `section.id` renders
   in the same panel; a different `id` renders a separate panel, ordered by
   `section.order`.
